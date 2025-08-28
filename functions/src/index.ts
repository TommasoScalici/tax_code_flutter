import { onCall, HttpsError } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import {
  VertexAI,
  GenerativeModel,
  HarmCategory,
  HarmBlockThreshold,
} from "@google-cloud/vertexai";

const LOCATION = "europe-west1";
const PROJECT_ID = "tax-code-flutter";
const SERVICE_ACCOUNT =
  "vertex-ai-invoker@tax-code-flutter.iam.gserviceaccount.com";

let vertexAI: VertexAI;
let generativeModel: GenerativeModel;

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
        model: "gemini-2.5-flash",
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
