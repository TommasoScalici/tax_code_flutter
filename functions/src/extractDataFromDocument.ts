import {
  GenerativeModel,
  HarmBlockThreshold,
  HarmCategory,
  VertexAI,
} from "@google-cloud/vertexai";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const LOCATION = "us-central1";
const PROJECT_ID = process.env.GCLOUD_PROJECT || "tax-code-flutter";
const SERVICE_ACCOUNT = `vertex-ai-invoker@${PROJECT_ID}.iam.gserviceaccount.com`;

let vertexAI: VertexAI;
let generativeModel: GenerativeModel;

interface ExtractDataRequest {
  image: string;
}

interface ExtractDataResponse {
  firstName: string | null;
  lastName: string | null;
  gender: string | null;
  birthPlace: {
    name: string | null;
    state: string | null;
  } | null;
  birthDate: string | null;
}

export const extractDataFromDocument = onCall<ExtractDataRequest>(
  {
    region: LOCATION,
    serviceAccount: SERVICE_ACCOUNT,
    maxInstances: 10,
  },
  async (request) => {
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
    } catch (error: unknown) {
      if (error instanceof HttpsError) throw error;

      const errorCode = (error as { code?: string | number })?.code;
      const errorMessage = (error as { message?: string })?.message;

      if (errorCode === 7 || errorCode === "permission-denied") {
        logger.error(
          "Firestore Permission Denied in document scan limit check.",
          {
            uid,
            detail: errorMessage,
          },
        );
        throw new HttpsError(
          "permission-denied",
          "Permesso negato durante il controllo dei limiti di scansione.",
        );
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
      logger.info("Sending request to Gemini Vision API.", { uid });

      const geminiRequest = {
        contents: [{ role: "user", parts: [imagePart, { text: prompt }] }],
      };

      const response = await generativeModel.generateContent(geminiRequest);
      const content = response.response.candidates?.[0]?.content;

      if (!content || !content.parts[0]?.text) {
        logger.error("Gemini API returned an empty or invalid response.", {
          uid,
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
        uid,
      });

      return JSON.parse(jsonResponseText) as ExtractDataResponse;
    } catch (error: unknown) {
      if (error instanceof HttpsError) throw error;

      logger.error("An error occurred while calling the Gemini API.", {
        error,
        uid: request.auth.uid,
      });

      // Handle common Vertex AI / Gemini API errors
      if (typeof error === "object" && error !== null && "status" in error) {
        const status = (error as { status: number }).status;
        if (status === 429) {
          throw new HttpsError(
            "unavailable",
            "The service is currently overloaded. Please try again later.",
          );
        }
      }

      throw new HttpsError(
        "internal",
        "The function encountered an error during processing.",
      );
    }
  },
);
