import * as cheerio from "cheerio";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";

// Function to perform the actual download and parse
export const downloadAndParseIstatData = async () => {
  logger.info("Starting ISTAT data fetch");
  const baseUrl =
    "https://www.istat.it/classificazione/codici-dei-comuni-delle-province-e-delle-regioni/";

  // 1. Scrape the page for the Excel file link
  const response = await fetch(baseUrl, {
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch ISTAT page: ${response.statusText}`);
  }

  const html = await response.text();
  const $ = cheerio.load(html);

  let excelUrl = "";
  $("a").each((_, el) => {
    const href = $(el).attr("href");
    if (
      href &&
      href.includes(".xlsx") &&
      href.toLowerCase().includes("comuni")
    ) {
      excelUrl = href;
    }
  });

  if (!excelUrl) {
    throw new Error("Could not find the Excel file link on the ISTAT page.");
  }

  if (!excelUrl.startsWith("http")) {
    excelUrl = new URL(excelUrl, baseUrl).toString();
  }

  logger.info(`Found Excel file at: ${excelUrl}`);

  // 2. Download the Excel file
  const excelResponse = await fetch(excelUrl, {
    headers: {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    },
  });
  if (!excelResponse.ok) {
    throw new Error(
      `Failed to download Excel file: ${excelResponse.statusText}`,
    );
  }
  const arrayBuffer = await excelResponse.arrayBuffer();

  // 3. Parse Excel file
  // Dynamically import exceljs to prevent a top-level module initialization timeout during Firebase Deploy
  const exceljsModule = await import("exceljs");
  const exceljs = exceljsModule.default || exceljsModule;
  const workbook = new exceljs.Workbook();
  await workbook.xlsx.load(arrayBuffer);
  const worksheet = workbook.worksheets[0];

  const rawData: unknown[][] = [];
  worksheet.eachRow({ includeEmpty: true }, (row) => {
    const rowData: unknown[] = [];
    row.eachCell({ includeEmpty: true }, (cell, colNumber) => {
      rowData[colNumber - 1] = cell.value != null ? cell.value.toString() : "";
    });
    for (let i = 0; i < rowData.length; i++) {
      if (rowData[i] === undefined) rowData[i] = "";
    }
    rawData.push(rowData);
  });

  if (rawData.length === 0) {
    throw new Error("Excel file is empty");
  }

  let headerRowIndex = -1;
  let nameColIndex = -1;
  let stateColIndex = -1;

  for (let i = 0; i < Math.min(20, rawData.length); i++) {
    const row = rawData[i];
    nameColIndex = row.findIndex(
      (c) =>
        typeof c === "string" &&
        c.toLowerCase().includes("denominazione") &&
        c.toLowerCase().includes("italiano"),
    );
    if (nameColIndex === -1) {
      nameColIndex = row.findIndex(
        (c) =>
          typeof c === "string" &&
          (c.toLowerCase().includes("denominazione in italiano") ||
            c.toLowerCase() === "denominazione"),
      );
    }

    stateColIndex = row.findIndex(
      (c) =>
        typeof c === "string" &&
        c.toLowerCase().includes("sigla automobilistica"),
    );

    if (nameColIndex !== -1 && stateColIndex !== -1) {
      headerRowIndex = i;
      break;
    }
  }

  if (headerRowIndex === -1) {
    throw new Error("Could not find required columns in the Excel file");
  }

  const cities: { name: string; state: string }[] = [];

  for (let i = headerRowIndex + 1; i < rawData.length; i++) {
    const row = rawData[i];
    const nameVal = row[nameColIndex];
    const name =
      typeof nameVal === "string"
        ? nameVal.trim()
        : nameVal != null
          ? String(nameVal).trim()
          : undefined;
    const stateVal = row[stateColIndex];
    const state =
      typeof stateVal === "string"
        ? stateVal.trim()
        : stateVal != null
          ? String(stateVal).trim()
          : undefined;

    if (name && state && state !== "-") {
      cities.push({ name, state });
    }
  }

  cities.sort((a, b) => a.name.localeCompare(b.name));

  logger.info(`Parsed ${cities.length} cities successfully.`);

  const jsonString = JSON.stringify(cities, null, 2);

  // 4. Upload to default Firebase Storage bucket
  const bucket = getStorage().bucket();
  const file = bucket.file("public/cities.json");

  await file.save(jsonString, {
    metadata: {
      contentType: "application/json",
      cacheControl: "public, max-age=86400",
    },
  });

  // Make it publicly accessible via direct link if needed
  await file.makePublic();

  logger.info(
    "Successfully saved cities.json to Firebase Storage public/cities.json",
  );
  return cities.length;
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

export const generateCitiesJson = onCall(
  { timeoutSeconds: 300, memory: "512MiB" },
  async () => {
    try {
      const count = await downloadAndParseIstatData();
      return { success: true, count };
    } catch (error: unknown) {
      logger.error("Error updating cities.json", error);
      const message = error instanceof Error ? error.message : "Unknown error";
      throw new HttpsError("internal", message);
    }
  },
);
