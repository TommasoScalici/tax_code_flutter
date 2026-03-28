import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const LOCATION = process.env.LOCATION || "europe-west1";

const MIO_CODICE_FISCALE_API_KEY = defineSecret("MIO_CODICE_FISCALE_API_KEY");

interface CalculateTaxCodeRequest {
  fname: string;
  lname: string;
  gender: "M" | "F";
  day: number;
  month: number;
  year: number;
  city: string;
  state: string;
}

interface CalculateTaxCodeResponse {
  tax_code: string;
  // Add other fields from the API if known, otherwise use unknown or specific types
  [key: string]: unknown;
}

export const calculateTaxCode = onCall<CalculateTaxCodeRequest>(
  { region: LOCATION, secrets: [MIO_CODICE_FISCALE_API_KEY] },
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
    try {
      await db.runTransaction(async (t) => {
        const doc = await t.get(rateLimitRef);
        const data = doc.data() || {};
        const MAX_CALLS_PER_DAY = 50;
        const todayStr = new Date().toISOString().split("T")[0];

        let callsToday = 0;
        if (data.date === todayStr) {
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
            date: todayStr,
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
        logger.error("Firestore Permission Denied in tax code limit check.", {
          uid,
          detail: errorMessage,
        });
        throw new HttpsError(
          "failed-precondition",
          "Internal service error while checking permissions.",
        );
      }

      logger.error("Rate limit check internal error", { error, uid });
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

    let apiKey: string;
    try {
      apiKey = MIO_CODICE_FISCALE_API_KEY.value();
    } catch (error: unknown) {
      logger.error("Failed to access API Key secret", { error, uid });
      throw new HttpsError("internal", "Service configuration error.");
    }

    const queryParams = new URLSearchParams({
      fname,
      lname,
      gender,
      day: String(day),
      month: String(month),
      year: String(year),
      city,
      state,
      access_token: apiKey,
    });

    const url = `https://api.miocodicefiscale.it/calculate?${queryParams.toString()}`;

    try {
      // 10s timeout for external API calls
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000);

      const maskedUrl = url.replace(apiKey, "REDACTED");
      logger.info(`Fetching tax code from: ${maskedUrl}`, { uid });

      const response = await fetch(url, {
        headers: {
          "User-Agent": "TaxCodeApp/1.1.0",
          Accept: "application/json",
        },
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        const errorBody = await response.text();
        logger.error("TaxCode API returned non-OK status", {
          status: response.status,
          statusText: response.statusText,
          body: errorBody,
          uid,
        });

        if (response.status === 429) {
          throw new HttpsError(
            "resource-exhausted",
            "Too many requests to the tax code service provider.",
          );
        }

        if (response.status >= 500) {
          throw new HttpsError(
            "unavailable",
            "The tax code service provider is currently unavailable.",
          );
        }

        throw new HttpsError(
          "internal",
          `TaxCode API error: ${response.status}`,
        );
      }

      const data = (await response.json()) as CalculateTaxCodeResponse;
      return data;
    } catch (error: unknown) {
      if (error instanceof HttpsError) throw error;

      const err = error instanceof Error ? error : new Error(String(error));

      if (err.name === "AbortError") {
        logger.warn("TaxCode API request timed out.", { uid });
        throw new HttpsError("deadline-exceeded", "The request took too long.");
      }

      // Safe access to 'cause'
      const cause = (err as { cause?: unknown })?.cause;

      logger.error("Unexpected error in TaxCode API fetch logic", {
        name: err.name,
        message: err.message,
        stack: err.stack,
        cause: cause,
        uid,
      });

      throw new HttpsError(
        "unavailable",
        "Unable to reach the calculation service.",
      );
    }
  },
);
