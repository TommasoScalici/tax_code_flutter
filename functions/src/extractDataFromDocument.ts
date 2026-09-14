import {
  GenerativeModel,
  HarmBlockThreshold,
  HarmCategory,
  SchemaType,
  VertexAI,
} from "@google-cloud/vertexai";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const LOCATION = process.env.VERTEX_LOCATION || "us-central1";
const PROJECT_ID = process.env.GCLOUD_PROJECT || "tax-code-flutter";
const SERVICE_ACCOUNT = `vertex-ai-invoker@${PROJECT_ID}.iam.gserviceaccount.com`;

const DEFAULT_MODEL = "gemini-3.8-flash";
const DEFAULT_FALLBACK_MODEL = "gemini-3.7-flash";
const CONFIG_TTL_MS = 10 * 60 * 1000; // 10 minutes cache

export interface AiConfig {
  model: string;
  fallbackModel: string;
  temperature: number;
  maxOutputTokens: number;
}

let cachedConfig: AiConfig | null = null;
let lastConfigFetchTime = 0;
let vertexAI: VertexAI;

export function resetCachedAiConfig(): void {
  cachedConfig = null;
  lastConfigFetchTime = 0;
}

export async function getAiConfig(): Promise<AiConfig> {
  const now = Date.now();
  if (cachedConfig && now - lastConfigFetchTime < CONFIG_TTL_MS) {
    return cachedConfig;
  }

  try {
    const db = getFirestore();
    const doc = await db.collection("systemConfig").doc("ai").get();
    if (doc.exists) {
      const data = doc.data();
      cachedConfig = {
        model:
          (data?.model as string) || process.env.GEMINI_MODEL || DEFAULT_MODEL,
        fallbackModel:
          (data?.fallbackModel as string) ||
          process.env.GEMINI_FALLBACK_MODEL ||
          DEFAULT_FALLBACK_MODEL,
        temperature:
          typeof data?.temperature === "number" ? data.temperature : 0.1,
        maxOutputTokens:
          typeof data?.maxOutputTokens === "number"
            ? data.maxOutputTokens
            : 2048,
      };
      lastConfigFetchTime = now;
      return cachedConfig;
    }
  } catch (error) {
    logger.warn(
      "Unable to fetch AI configuration from Firestore, using defaults.",
      { error },
    );
  }

  cachedConfig = {
    model: process.env.GEMINI_MODEL || DEFAULT_MODEL,
    fallbackModel: process.env.GEMINI_FALLBACK_MODEL || DEFAULT_FALLBACK_MODEL,
    temperature: 0.1,
    maxOutputTokens: 2048,
  };
  lastConfigFetchTime = now;
  return cachedConfig;
}

const DOCUMENT_SCHEMA = {
  type: SchemaType.OBJECT,
  properties: {
    firstName: {
      type: SchemaType.STRING,
      description: "First name extracted from the document, or null if absent",
      nullable: true,
    },
    lastName: {
      type: SchemaType.STRING,
      description: "Last name extracted from the document, or null if absent",
      nullable: true,
    },
    gender: {
      type: SchemaType.STRING,
      description: "Gender ('M' or 'F'), or null if absent",
      nullable: true,
    },
    birthPlace: {
      type: SchemaType.OBJECT,
      description: "Place of birth details, or null if absent",
      nullable: true,
      properties: {
        name: {
          type: SchemaType.STRING,
          description:
            "Municipality name or foreign country, or null if absent",
          nullable: true,
        },
        state: {
          type: SchemaType.STRING,
          description:
            "2-letter province abbreviation, or 'EE' for foreign country, or null",
          nullable: true,
        },
      },
    },
    birthDate: {
      type: SchemaType.STRING,
      description:
        "Birth date formatted strictly as 'YYYY-MM-DD', or null if absent",
      nullable: true,
    },
  },
};

function getGenerativeModel(
  modelName: string,
  config: AiConfig,
): GenerativeModel {
  if (!vertexAI) {
    vertexAI = new VertexAI({ project: PROJECT_ID, location: LOCATION });
  }

  return vertexAI.getGenerativeModel({
    model: modelName,
    systemInstruction:
      "You are an expert document parser. Your task is to extract demographic data from Italian documents and format them strictly into JSON according to the prompt instructions.",
    safetySettings: [
      {
        category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
        threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
      },
    ],
    generationConfig: {
      maxOutputTokens: config.maxOutputTokens,
      temperature: config.temperature,
      responseMimeType: "application/json",
      responseSchema: DOCUMENT_SCHEMA,
    },
  });
}

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
    const MAX_CALLS_PER_DAY = 15;
    const today = new Date().toISOString().split("T")[0];

    // Pre-check: read current rate limit without consuming it
    try {
      const doc = await rateLimitRef.get();
      const data = doc.data() || {};
      const callsToday = data.date === today ? data.count || 0 : 0;

      if (callsToday >= MAX_CALLS_PER_DAY) {
        logger.warn(
          `User ${uid} exceeded daily limit of ${MAX_CALLS_PER_DAY} for document processing.`,
        );
        throw new HttpsError(
          "resource-exhausted",
          "You have exceeded your daily limit for document processing.",
        );
      }
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
          "Permission denied while checking scan limits.",
        );
      }

      logger.error("Error checking rate limit", { error, uid });
      throw new HttpsError("internal", "Error enforcing rate limit.");
    }

    const rawImage = request.data.image;
    if (typeof rawImage !== "string" || !rawImage.trim()) {
      logger.error("Image data is missing or invalid from the request.");
      throw new HttpsError(
        "invalid-argument",
        "The function must be called with an 'image' argument.",
      );
    }

    const cleanBase64 = rawImage.replace(/^data:image\/\w+;base64,/, "").trim();
    const MAX_BASE64_BYTES = 10 * 1024 * 1024; // 10MB limit

    if (cleanBase64.length > MAX_BASE64_BYTES) {
      logger.error("Image payload exceeds maximum allowed size.", {
        size: cleanBase64.length,
      });
      throw new HttpsError(
        "invalid-argument",
        "The image payload exceeds the maximum allowed size limit (10MB).",
      );
    }

    const imagePart = {
      inlineData: {
        data: cleanBase64,
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

    const config = await getAiConfig();
    const geminiRequest = {
      contents: [{ role: "user", parts: [imagePart, { text: prompt }] }],
    };

    let content;
    try {
      logger.info(
        `Sending request to Gemini Vision API using model ${config.model}.`,
        { uid },
      );
      const primaryModel = getGenerativeModel(config.model, config);
      const response = await primaryModel.generateContent(geminiRequest);
      content = response.response.candidates?.[0]?.content;
    } catch (primaryError: unknown) {
      logger.warn(
        `Primary model ${config.model} failed. Attempting fallback model ${config.fallbackModel}.`,
        { error: primaryError, uid },
      );

      try {
        const fallbackModel = getGenerativeModel(config.fallbackModel, config);
        const fallbackResponse =
          await fallbackModel.generateContent(geminiRequest);
        content = fallbackResponse.response.candidates?.[0]?.content;
      } catch (fallbackError: unknown) {
        if (
          typeof fallbackError === "object" &&
          fallbackError !== null &&
          "status" in fallbackError
        ) {
          const status = (fallbackError as { status: number }).status;
          if (status === 429) {
            throw new HttpsError(
              "unavailable",
              "The service is currently overloaded. Please try again later.",
            );
          }
        }

        logger.error("Both primary and fallback Gemini models failed.", {
          primaryError,
          fallbackError,
          uid,
        });
        throw new HttpsError(
          "internal",
          "The function encountered an error during processing.",
        );
      }
    }

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

    let parsedData: ExtractDataResponse;
    try {
      parsedData = JSON.parse(jsonResponseText) as ExtractDataResponse;
    } catch (jsonErr) {
      logger.error("Failed to parse Gemini JSON output.", {
        jsonErr,
        jsonResponseText,
        uid,
      });
      throw new HttpsError(
        "internal",
        "Failed to parse document extraction data.",
      );
    }

    // Only increment rate limit consumption AFTER successful extraction
    try {
      await db.runTransaction(async (t) => {
        const freshDoc = await t.get(rateLimitRef);
        const freshData = freshDoc.data() || {};
        const freshCalls = freshData.date === today ? freshData.count || 0 : 0;

        t.set(
          rateLimitRef,
          {
            date: today,
            count: freshCalls + 1,
            lastUpdated: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
      });
      logger.info(
        "Successfully updated rate limit counter after document scan.",
        { uid },
      );
    } catch (rateLimitErr) {
      logger.warn(
        "Failed to update rate limit counter after successful document scan.",
        { rateLimitErr, uid },
      );
    }

    return parsedData;
  },
);
