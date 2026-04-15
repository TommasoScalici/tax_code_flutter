import { execSync } from "child_process";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { unlinkSync, writeFileSync } from "fs";
import { join } from "path";

/**
 * Represents a birthplace (city or country).
 */
export interface Birthplace {
  name: string;
  state: string;
}

const LOCATION = "us-central1";
const STORAGE_PATH = "public/birthplaces.json";

// ISTAT JSON API for Italian municipalities
const ITALIAN_MUNICIPALITIES_API =
  "https://situas-servizi.istat.it/publish/reportspooljson";
// ISTAT ZIP for foreign countries
const FOREIGN_COUNTRIES_ZIP_URL =
  "https://www.istat.it/wp-content/uploads/2024/03/Elenco-codici-e-denominazioni-unita-territoriali-estere.zip";
const CSV_FILENAME_PATTERN = "denominazioni-al-31_12_2023.csv";

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
    resultset: Array<{ COMUNE: string; SIGLA_AUTOMOBILISTICA: string }>;
  };
  if (!data.resultset || !Array.isArray(data.resultset)) {
    throw new Error("Invalid response format from Italian municipalities API");
  }

  return data.resultset.map((item) => ({
    name: item.COMUNE.trim(),
    state: item.SIGLA_AUTOMOBILISTICA.trim(),
  }));
}

/**
 * Simple CSV parser for semicolon-delimited files.
 */
function parseCSV(content: string, delimiter: string = ";"): string[][] {
  const lines = content.split(/\r?\n/);
  return lines
    .map((line) =>
      line.split(delimiter).map((cell) => cell.replace(/^"|"$/g, "").trim()),
    )
    .filter((row) => row.length > 1 && row.some((cell) => cell !== ""));
}

/**
 * Parses the foreign countries CSV content.
 */
function parseForeignCountriesCSV(content: string): Birthplace[] {
  const rows = parseCSV(content);

  if (rows.length < 2) {
    throw new Error("Foreign countries CSV is empty or invalid");
  }

  const headers = rows[0];
  const normalizedHeaders = headers.map((h) =>
    h
      .toLowerCase()
      .trim()
      .replace(/[\s()]+/g, "_")
      .replace(/^_+|_+$/g, ""),
  );

  const nameIdx = normalizedHeaders.indexOf("denominazione_it");

  const results: Birthplace[] = [];
  if (nameIdx !== -1) {
    for (let i = 1; i < rows.length; i++) {
      const row = rows[i];
      if (row.length <= nameIdx) continue;

      const name = row[nameIdx]?.trim();
      if (name) {
        results.push({ name, state: "EE" });
      }
    }
  }

  return results.filter((b) => b.name && b.name.toLowerCase() !== "italia"); // Exclude Italy as it is handled by the other API
}

/**
 * Fetches foreign countries from ISTAT ZIP.
 */
async function fetchForeignCountries(): Promise<Birthplace[]> {
  logger.info(`Fetching foreign countries from: ${FOREIGN_COUNTRIES_ZIP_URL}`);

  const response = await fetch(FOREIGN_COUNTRIES_ZIP_URL);
  if (!response.ok) {
    throw new Error(
      `Failed to fetch foreign countries ZIP: ${response.statusText}`,
    );
  }

  const arrayBuffer = await response.arrayBuffer();
  const buffer = Buffer.from(arrayBuffer);
  const zipPath = join("/tmp", "countries.zip");
  writeFileSync(zipPath, buffer);

  let content: string;
  try {
    // Extract the CSV content to stdout using unzip -p with wildcard.
    // Using latin1 encoding for ISTAT CSV files to preserve special characters.
    content = execSync(
      `unzip -p ${zipPath} "*${CSV_FILENAME_PATTERN}"`,
    ).toString("latin1");
  } catch (error) {
    // Fallback attempt: if zip folder structure is different, try listing files.
    logger.warn("Primary zip extraction failed, trying fallback...", { error });
    const listOutput = execSync(`unzip -l ${zipPath}`).toString();
    const match = listOutput.match(/\s(\S+denominazioni-al-31_12_2023\.csv)/i);
    if (!match) {
      throw new Error(`Could not find CSV in ZIP: ${listOutput}`, {
        cause: error,
      });
    }
    content = execSync(`unzip -p ${zipPath} "${match[1]}"`).toString("latin1");
  } finally {
    try {
      unlinkSync(zipPath);
    } catch {
      // Ignore cleanup errors
    }
  }

  return parseForeignCountriesCSV(content);
}

/**
 * Orchestrates the download, parsing, and storage of birthplace data.
 */
export async function downloadAndParseBirthplaceData(): Promise<number> {
  logger.info("Starting birthplace data update");

  const [italian, foreign] = await Promise.all([
    fetchItalianMunicipalities(),
    fetchForeignCountries().catch((err) => {
      logger.error(
        "Foreign countries fetch failed, continuing with Italian data only",
        { err },
      );
      return [] as Birthplace[];
    }),
  ]);

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
