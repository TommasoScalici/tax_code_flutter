import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import foreignCountriesData from "./foreign_countries.json";

/**
 * Represents a birthplace (city or country).
 */
export interface Birthplace {
  name: string;
  state: string;
  code: string;
}

const LOCATION = "us-central1";
const STORAGE_PATH = "public/birthplaces.json";

// ISTAT JSON API for Italian municipalities
const ITALIAN_MUNICIPALITIES_API =
  "https://situas-servizi.istat.it/publish/reportspooljson";

/**
 * Returns the current date in DD/MM/YYYY format for the ISTAT API.
 */
function getFormattedDate(): string {
  const now = new Date();
  const d = String(now.getDate()).padStart(2, "0");
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const y = now.getFullYear();
  return `${d}/${m}/${y}`;
}

/**
 * Fetches Italian municipalities from ISTAT JSON API.
 */
async function fetchItalianMunicipalities(): Promise<Birthplace[]> {
  const url = `${ITALIAN_MUNICIPALITIES_API}?pfun=61&pdata=${getFormattedDate()}`;
  logger.info(`Fetching Italian municipalities from: ${url}`);

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(
      `Failed to fetch Italian municipalities: ${response.statusText}`,
    );
  }

  const data = (await response.json()) as {
    resultset: Array<{
      COMUNE: string;
      SIGLA_AUTOMOBILISTICA: string;
      COD_CATASTO: string;
    }>;
  };
  if (!data.resultset || !Array.isArray(data.resultset)) {
    throw new Error("Invalid response format from Italian municipalities API");
  }

  return data.resultset.map((item) => ({
    name: item.COMUNE.trim(),
    state: item.SIGLA_AUTOMOBILISTICA.trim(),
    code: item.COD_CATASTO.trim(),
  }));
}

/**
 * Loads foreign countries from the local JSON dataset.
 */
function getForeignCountries(): Birthplace[] {
  const list = foreignCountriesData as Array<{
    nome: string;
    codiceCatastale: string;
  }>;
  return list
    .filter((item) => item.codiceCatastale && item.codiceCatastale !== "n.d.")
    .map((item) => ({
      name: item.nome,
      state: "EE",
      code: item.codiceCatastale,
    }));
}

/**
 * Orchestrates the download, parsing, and storage of birthplace data.
 */
export async function downloadAndParseBirthplaceData(): Promise<number> {
  logger.info("Starting birthplace data update");

  const italian = await fetchItalianMunicipalities();
  const foreign = getForeignCountries();

  const combined = [...italian, ...foreign];

  const unique = Array.from(
    new Map(
      combined.map((b) => [`${b.name.toLowerCase()}|${b.state}`, b]),
    ).values(),
  );

  unique.sort((a, b) => a.name.localeCompare(b.name, "it"));

  const jsonString = JSON.stringify(unique);
  const bucket = getStorage().bucket();
  const file = bucket.file(STORAGE_PATH);

  await file.save(jsonString, {
    metadata: {
      contentType: "application/json",
      cacheControl: "public, max-age=86400",
    },
  });

  await file.makePublic();

  logger.info(
    `Successfully saved ${unique.length} birthplaces to ${STORAGE_PATH}`,
  );
  return unique.length;
}

/**
 * Scheduled function to update birthplaces once a year.
 */
export const updateBirthplacesScheduled = onSchedule(
  {
    region: LOCATION,
    schedule: "0 0 1 3 *", // March 1st
    timeZone: "Europe/Rome",
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async () => {
    await downloadAndParseBirthplaceData();
  },
);

/**
 * On-call function for manual triggers by admins.
 */
export const updateBirthplaces = onCall<void>(
  {
    region: LOCATION,
    timeoutSeconds: 300,
    memory: "512MiB",
    maxInstances: 3,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Authentication required");
    }

    const bucket = getStorage().bucket();
    const file = bucket.file(STORAGE_PATH);
    const [exists] = await file.exists();

    if (exists && !request.auth.token?.admin) {
      throw new HttpsError(
        "permission-denied",
        "Admin privileges required to force update existing data",
      );
    }

    try {
      const count = await downloadAndParseBirthplaceData();
      return { success: true, count };
    } catch (error) {
      logger.error("Error updating birthplaces", { error });
      throw new HttpsError(
        "internal",
        error instanceof Error ? error.message : "Unknown error",
      );
    }
  },
);
