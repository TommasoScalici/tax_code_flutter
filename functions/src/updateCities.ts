import ExcelJS from "exceljs";
import { Buffer } from "node:buffer";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import JSZip from "jszip";

interface Birthplace {
  name: string;
  state: string;
}

/**
 * Downloads and parses an Excel file from a direct URL.
 * @param {string} url The direct URL of the Excel file.
 * @return {Promise<unknown[][]>} A 2D array representing the raw data rows.
 */
export async function fetchExcelData(url: string): Promise<unknown[][]> {
  logger.info(`Fetching Excel data from: ${url}`);

  const response = await fetch(url, {
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch Excel file: ${response.statusText}`);
  }

  const arrayBuffer = await response.arrayBuffer();
  const workbook = new ExcelJS.Workbook();
  // @ts-expect-error - ExcelJS types conflict with modern Node.js Buffer types
  await workbook.xlsx.load(Buffer.from(arrayBuffer));
  const worksheet = workbook.worksheets[0];

  const rawData: unknown[][] = [];
  worksheet.eachRow({ includeEmpty: true }, (row: ExcelJS.Row) => {
    const rowData: unknown[] = [];
    row.eachCell(
      { includeEmpty: true },
      (cell: ExcelJS.Cell, colNumber: number) => {
        rowData[colNumber - 1] =
          cell.value != null ? cell.value.toString() : "";
      },
    );
    for (let i = 0; i < rowData.length; i++) {
      if (rowData[i] === undefined) rowData[i] = "";
    }
    rawData.push(rowData);
  });

  return rawData;
}

/**
 * Downloads a ZIP file, extracts an Excel file matching keywords, and parses it.
 * @param {string} url The URL of the ZIP file.
 * @param {string[]} fileNameKeywords Keywords to identify the Excel file inside the ZIP.
 * @return {Promise<unknown[][]>} A 2D array representing the raw data rows.
 */
export async function fetchExcelDataFromZip(
  url: string,
  fileNameKeywords: string[],
): Promise<unknown[][]> {
  logger.info(`Fetching ZIP data from: ${url}`);

  const response = await fetch(url, {
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch ZIP file: ${response.statusText}`);
  }

  const arrayBuffer = await response.arrayBuffer();
  const zip = await JSZip.loadAsync(arrayBuffer);

  const excelFileEntry = Object.keys(zip.files).find((name) => {
    const lowerName = name.toLowerCase();
    return (
      lowerName.endsWith(".xlsx") &&
      fileNameKeywords.every((kw) => lowerName.includes(kw.toLowerCase()))
    );
  });

  if (!excelFileEntry) {
    throw new Error(
      `Could not find Excel file in ZIP matching keywords: ${fileNameKeywords.join(", ")}`,
    );
  }

  logger.info(`Extracting Excel file from ZIP: ${excelFileEntry}`);
  const excelBuffer = await zip.files[excelFileEntry].async("nodebuffer");

  const workbook = new ExcelJS.Workbook();
  // @ts-expect-error - ExcelJS types conflict with modern Node.js Buffer types
  await workbook.xlsx.load(Buffer.from(excelBuffer));
  const worksheet = workbook.worksheets[0];

  const rawData: unknown[][] = [];
  worksheet.eachRow({ includeEmpty: true }, (row: ExcelJS.Row) => {
    const rowData: unknown[] = [];
    row.eachCell(
      { includeEmpty: true },
      (cell: ExcelJS.Cell, colNumber: number) => {
        rowData[colNumber - 1] =
          cell.value != null ? cell.value.toString() : "";
      },
    );
    for (let i = 0; i < rowData.length; i++) {
      if (rowData[i] === undefined) rowData[i] = "";
    }
    rawData.push(rowData);
  });

  return rawData;
}

/**
 * Extracts birthplace data from raw Excel rows.
 */
export function extractBirthplaces(
  rawData: unknown[][],
  columnMatchers: {
    name: (cell: string) => boolean;
    state?: (cell: string) => boolean;
  },
  overrides?: { state?: string },
): Birthplace[] {
  if (rawData.length === 0) return [];

  let headerRowIndex = -1;
  let nameColIndex = -1;
  let stateColIndex = -1;

  // Find header row and columns
  for (let i = 0; i < Math.min(30, rawData.length); i++) {
    const row = rawData[i];
    nameColIndex = row.findIndex(
      (c) => typeof c === "string" && columnMatchers.name(c.toLowerCase()),
    );

    if (columnMatchers.state) {
      stateColIndex = row.findIndex(
        (c) => typeof c === "string" && columnMatchers.state!(c.toLowerCase()),
      );
    }

    if (
      nameColIndex !== -1 &&
      (columnMatchers.state === undefined || stateColIndex !== -1)
    ) {
      headerRowIndex = i;
      break;
    }
  }

  if (headerRowIndex === -1) {
    throw new Error("Could not find required columns in the raw data");
  }

  const birthplaces: Birthplace[] = [];

  for (let i = headerRowIndex + 1; i < rawData.length; i++) {
    const row = rawData[i];
    const nameVal = row[nameColIndex];
    const name =
      nameVal != null ? String(nameVal).trim().toUpperCase() : undefined;

    let state: string | undefined;
    if (overrides?.state) {
      state = overrides.state.toUpperCase();
    } else if (stateColIndex !== -1) {
      const stateVal = row[stateColIndex];
      state =
        stateVal != null ? String(stateVal).trim().toUpperCase() : undefined;
    }

    if (name && state && state !== "-") {
      birthplaces.push({ name, state });
    }
  }

  return birthplaces;
}

/**
 * Main function to download and parse ISTAT data for both Italian cities and foreign countries.
 */
export const downloadAndParseIstatData = async () => {
  logger.info("Starting consolidated ISTAT data fetch");

  // 1. Fetch Italian Municipalities (Direct Link)
  const municipalitiesUrl =
    "https://www.istat.it/storage/codici-unita-amministrative/Elenco-comuni-italiani.xlsx";
  const municipalityRows = await fetchExcelData(municipalitiesUrl);
  const cities = extractBirthplaces(municipalityRows, {
    name: (c) =>
      c.includes("denominazione") &&
      (c.includes("italiano") || c === "denominazione"),
    state: (c) => c.includes("sigla automobilistica"),
  });
  logger.info(`Extracted ${cities.length} Italian cities.`);

  // 2. Fetch Foreign Countries (Direct ZIP Link)
  const countriesZipUrl =
    "https://www.istat.it/wp-content/uploads/2024/03/Elenco-codici-e-denominazioni-unita-territoriali-estere.zip";
  let countries: Birthplace[] = [];
  try {
    const countryRows = await fetchExcelDataFromZip(countriesZipUrl, [
      "Elenco",
      "denominazioni",
    ]);
    countries = extractBirthplaces(
      countryRows,
      {
        name: (c) =>
          (c.includes("denominazione") || c.includes("stato")) &&
          (c.includes("italiano") ||
            c.includes("italiana") ||
            c.includes(" it")),
      },
      { state: "EE" },
    );
    logger.info(`Extracted ${countries.length} foreign countries.`);
  } catch (err) {
    logger.error(
      "Failed to fetch foreign countries, continuing with Italian cities only",
      { error: err },
    );
  }

  // 3. Merge and Sort
  const combined = [...cities, ...countries];
  combined.sort((a, b) => a.name.localeCompare(b.name));

  const jsonString = JSON.stringify(combined, null, 2);

  // 4. Save to Storage
  const bucket = getStorage().bucket();
  const file = bucket.file("public/cities.json");

  await file.save(jsonString, {
    metadata: {
      contentType: "application/json",
      cacheControl: "public, max-age=86400",
    },
  });

  await file.makePublic();

  logger.info(
    `Successfully saved ${combined.length} birthplaces to public/cities.json`,
  );
  return combined.length;
};

export const updateCitiesJsonScheduled = onSchedule(
  {
    schedule: "0 0 1 3 *", // March 1st every year
    timeZone: "Europe/Rome",
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async () => {
    await downloadAndParseIstatData();
  },
);

export const updateCities = onCall<void>(
  { timeoutSeconds: 300, memory: "512MiB" },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "The function must be called while authenticated.",
      );
    }

    const isAdmin = !!request.auth.token.admin;
    if (!isAdmin) {
      throw new HttpsError(
        "permission-denied",
        "The function must be called by an administrator.",
      );
    }

    try {
      const count = await downloadAndParseIstatData();
      return { success: true, count };
    } catch (error: unknown) {
      logger.error("Error updating cities.json", { error });
      const message = error instanceof Error ? error.message : "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);
