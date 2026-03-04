import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineString } from "firebase-functions/params";
import { logger } from "firebase-functions";
import {
  VertexAI,
  GenerativeModel,
  HarmCategory,
  HarmBlockThreshold,
} from "@google-cloud/vertexai";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { initializeApp } from "firebase-admin/app";

initializeApp();

const LOCATION = process.env.LOCATION || "europe-west1";
const PROJECT_ID = process.env.GCLOUD_PROJECT;
if (!PROJECT_ID) {
  throw new Error("GCLOUD_PROJECT environment variable is not set.");
}
const SERVICE_ACCOUNT = `vertex-ai-invoker@${PROJECT_ID}.iam.gserviceaccount.com`;

let vertexAI: VertexAI;
let generativeModel: GenerativeModel;

const MIO_CODICE_FISCALE_API_KEY = defineString("MIO_CODICE_FISCALE_API_KEY");

export const calculateTaxCode = onCall(
  { region: LOCATION },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const uid = request.auth.uid;
    const db = getFirestore();
    const rateLimitRef = db.collection("rateLimitsTaxCode").doc(uid);
    const MAX_CALLS_PER_DAY = 50;
    const today = new Date().toISOString().split("T")[0];

    try {
      await db.runTransaction(async (t) => {
        const doc = await t.get(rateLimitRef);
        const data = doc.data() || {};
        let callsToday = 0;

        if (data.date === today) {
          callsToday = data.count || 0;
        }

        if (callsToday >= MAX_CALLS_PER_DAY) {
          logger.warn(`User ${uid} exceeded daily tax code limit.`);
          throw new HttpsError(
            "resource-exhausted",
            "Daily limit for tax code calculations reached.",
          );
        }

        t.set(
          rateLimitRef,
          {
            date: today,
            count: callsToday + 1,
            lastUpdated: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      });
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      logger.error("Rate limit error", { error, uid });
      throw new HttpsError("internal", "Error enforcing rate limit.");
    }

    const { fname, lname, gender, day, month, year, city, state } =
      request.data;

    if (
      !fname ||
      !lname ||
      !gender ||
      !day ||
      !month ||
      !year ||
      !city ||
      !state
    ) {
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with all required birth data.",
      );
    }

    const queryParams = new URLSearchParams({
      fname,
      lname,
      gender,
      day,
      month,
      year,
      city,
      state,
      access_token: MIO_CODICE_FISCALE_API_KEY.value(),
    });

    const url = `https://api.miocodicefiscale.com/calculate?${queryParams.toString()}`;

    try {
      const response = await fetch(url);
      if (!response.ok) {
        logger.error("TaxCode API error", {
          status: response.status,
          uid: request.auth.uid,
        });
        throw new HttpsError("internal", "TaxCode API returned an error.");
      }

      return await response.json();
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      logger.error("Unexpected error calling TaxCode API", {
        error,
        uid: request.auth.uid,
      });
      throw new HttpsError("internal", "Failed to calculate tax code.");
    }
  },
);

export const extractDataFromDocument = onCall(
  { region: LOCATION, serviceAccount: SERVICE_ACCOUNT },
  async (request) => {
    /**
     * Analyzes an image of an Italian ID or health card to extract personal data.
     * @param {object} request The request object from the client.
     * @param {string} request.data.image The Base64 encoded image string.
     * @returns {Promise<object>} A JSON object structured like the 'Contact' Dart model.
     */

    if (!vertexAI) {
      logger.info("Initializing Vertex AI client for the first time.");
      vertexAI = new VertexAI({ project: PROJECT_ID, location: LOCATION });

      generativeModel = vertexAI.getGenerativeModel({
        model: "gemini-flash-latest",
        safetySettings: [
          {
            category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
          },
        ],
        generationConfig: {
          maxOutputTokens: 2048,
          temperature: 0.1,
        },
      });
    }

    if (!request.auth) {
      logger.error("Authentication failed. User is not authenticated.");
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const uid = request.auth.uid;
    const db = getFirestore();
    const rateLimitRef = db.collection("rateLimits").doc(uid);
    const MAX_CALLS_PER_DAY = 15; // Set quota rate limit
    const today = new Date().toISOString().split("T")[0];

    try {
      await db.runTransaction(async (t) => {
        const doc = await t.get(rateLimitRef);
        const data = doc.data() || {};
        let callsToday = 0;

        if (data.date === today) {
          callsToday = data.count || 0;
        }

        if (callsToday >= MAX_CALLS_PER_DAY) {
          logger.warn(
            `User ${uid} exceeded daily limit of ${MAX_CALLS_PER_DAY} for the Gemini API.`,
          );
          throw new HttpsError(
            "resource-exhausted",
            "You have exceeded your daily limit for document processing.",
          );
        }

        t.set(
          rateLimitRef,
          {
            date: today,
            count: callsToday + 1,
            lastUpdated: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      });
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      logger.error("Error executing rate limit transaction", { error, uid });
      throw new HttpsError("internal", "Error enforcing rate limit.");
    }

    if (!request.data.image) {
      logger.error("Image data is missing from the request.");
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with an 'image' argument.",
      );
    }

    const base64Image = request.data.image;
    const imagePart = {
      inlineData: {
        data: base64Image,
        mimeType: "image/jpeg",
      },
    };

    const prompt = `
    Analyze the provided image of an Italian document (identity card 'carta d'identità' or health card 'tessera sanitaria').
    Extract the following fields: first name, last name, gender ('M' or 'F'), date of birth, and place of birth.
    DO NOT extract or calculate the tax code (codice fiscale).
    
    Format the date of birth, which might appear as GG/MM/AAAA on the document, into the 'YYYY-MM-DD' format.
    Format the place of birth as an object containing the municipality name ('name') and its province abbreviation ('state'), for example { "name": "Roma", "state": "RM" }.

    Return the result ONLY as a valid JSON object matching this exact structure. If a field is not found, return null for that value.
    {
      "firstName": "...",
      "lastName": "...",
      "gender": "...",
      "birthPlace": {
        "name": "...",
        "state": "..."
      },
      "birthDate": "YYYY-MM-DD"
    }
    Do not include any other text, explanation, or markdown formatting in your response.
  `;

    try {
      logger.info("Sending request to Gemini Vision API.", {
        uid: request.auth.uid,
      });

      const geminiRequest = {
        contents: [{ role: "user", parts: [imagePart, { text: prompt }] }],
      };

      const response = await generativeModel.generateContent(geminiRequest);
      const content = response.response.candidates?.[0]?.content;

      if (!content || !content.parts[0]?.text) {
        logger.error("Gemini API returned an empty or invalid response.", {
          uid: request.auth.uid,
        });
        throw new HttpsError(
          "internal",
          "Failed to extract data from the document.",
        );
      }

      const jsonResponseText = content.parts[0].text
        .replace(/```json|```/g, "")
        .trim();
      logger.info("Successfully received and parsed response from Gemini.", {
        uid: request.auth.uid,
      });

      return JSON.parse(jsonResponseText);
    } catch (error) {
      logger.error("An error occurred while calling the Gemini API.", {
        error,
        uid: request.auth.uid,
      });
      throw new HttpsError(
        "internal",
        "An error occurred while processing the image.",
      );
    }
  },
);
