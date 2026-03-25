import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineString } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

const LOCATION = process.env.LOCATION || "europe-west1";

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
