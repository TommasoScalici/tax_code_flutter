import ExcelJS from "exceljs";
import fft from "firebase-functions-test";
import { beforeEach, describe, expect, it, vi } from "vitest";

import {
  extractBirthplaces,
  fetchExcelData,
  updateCities,
  updateCitiesJsonScheduled,
} from "../src/updateCities.js";

const testEnv = fft();

// Mock fetch
global.fetch = vi.fn();

// Mock firebase-admin
vi.mock("firebase-admin/storage", () => ({
  getStorage: () => ({
    bucket: () => ({
      file: () => ({
        save: vi.fn().mockResolvedValue(true),
        makePublic: vi.fn().mockResolvedValue(true),
      }),
    }),
  }),
}));

// Mock JSZip
vi.mock("jszip", () => {
  return {
    default: {
      loadAsync: vi.fn().mockResolvedValue({
        files: {
          "Elenco_paesi_esteri_denominazioni.xlsx": {
            async: vi.fn().mockResolvedValue(Buffer.from("mock content")),
          },
        },
      }),
    },
  };
});

// Mock ExcelJS
vi.mock("exceljs", () => {
  return {
    default: {
      Workbook: class {
        xlsx = {
          load: vi.fn().mockResolvedValue({}),
        };
        worksheets = [
          {
            eachRow: (
              opts: ExcelJS.EachRowOptions,
              cb: (row: ExcelJS.Row, rowNumber: number) => void,
            ) => {
              // Row 1: Header
              const headerRow = {
                eachCell: (
                  cellOpts: ExcelJS.EachCellOptions,
                  cellCb: (cell: ExcelJS.Cell, colNumber: number) => void,
                ) => {
                  cellCb(
                    { value: "denominazione italiano" } as ExcelJS.Cell,
                    1,
                  );
                  cellCb({ value: "sigla automobilistica" } as ExcelJS.Cell, 2);
                },
              } as ExcelJS.Row;
              cb(headerRow, 1);

              // Row 2: Data
              const dataRow = {
                eachCell: (
                  cellOpts: ExcelJS.EachCellOptions,
                  cellCb: (cell: ExcelJS.Cell, colNumber: number) => void,
                ) => {
                  cellCb({ value: "ROMA" } as ExcelJS.Cell, 1);
                  cellCb({ value: "RM" } as ExcelJS.Cell, 2);
                },
              } as ExcelJS.Row;
              cb(dataRow, 2);
            },
          },
        ];
      },
    },
  };
});

describe("updateCities core logic", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should handle download success and load workbook", async () => {
    vi.mocked(global.fetch).mockResolvedValue({
      ok: true,
      arrayBuffer: async () => new ArrayBuffer(8),
    } as Response);

    const result = await fetchExcelData("https://example.com/file");
    expect(result).toBeDefined();
  });

  it("should handle download failure", async () => {
    vi.mocked(global.fetch).mockResolvedValue({
      ok: false,
      statusText: "Not Found",
    } as Response);

    await expect(fetchExcelData("https://example.com/file")).rejects.toThrow(
      "Failed to fetch Excel file: Not Found",
    );
  });

  it("should correctly extract birthplaces from valid rows", () => {
    const rawData = [
      ["denominazione", "sigla automobilistica"],
      ["ROMA", "RM"],
      ["MILANO", "MI"],
    ];
    const cities = extractBirthplaces(rawData, {
      name: (c) => c.includes("denominazione"),
      state: (c) => c.includes("sigla automobilistica"),
    });

    expect(cities).toHaveLength(2);
    expect(cities[0].name).toBe("ROMA");
    expect(cities[1].state).toBe("MI");
  });

  describe("updateCities Cloud Function", () => {
    it("should throw unauthenticated error if no auth context", async () => {
      const wrapped = testEnv.wrap(updateCities);
      await expect(wrapped({})).rejects.toThrow(
        "The function must be called while authenticated.",
      );
    });

    it("should throw permission denied error if not admin", async () => {
      const wrapped = testEnv.wrap(updateCities);
      await expect(
        wrapped({
          auth: { uid: "test-user", token: { admin: false } },
        }),
      ).rejects.toThrow("The function must be called by an administrator.");
    });

    it("should succeed and perform full ingestion if admin", async () => {
      // Setup fetch mocks for both calls
      vi.mocked(global.fetch)
        .mockResolvedValueOnce({
          ok: true,
          arrayBuffer: async () => new ArrayBuffer(8),
        } as Response) // Italian cities
        .mockResolvedValueOnce({
          ok: true,
          arrayBuffer: async () => new ArrayBuffer(8),
        } as Response); // Foreign countries

      const wrapped = testEnv.wrap(updateCities);
      const result = await wrapped({
        auth: { uid: "test-admin", token: { admin: true } },
      });

      expect(result.success).toBe(true);
      expect(result.count).toBeGreaterThanOrEqual(1);
    });

    it("should handle failures in downloadAndParseIstatData", async () => {
      // Mock fetch failure specifically for this test
      vi.mocked(global.fetch).mockRejectedValueOnce(new Error("Network fail"));

      const wrapped = testEnv.wrap(updateCities);
      await expect(
        wrapped({
          auth: { token: { admin: true } },
        }),
      ).rejects.toThrow("Network fail");
    });
  });

  describe("updateCitiesJsonScheduled", () => {
    it("should call downloadAndParseIstatData", async () => {
      // Mock successful fetch for schedule
      vi.mocked(global.fetch).mockResolvedValue({
        ok: true,
        arrayBuffer: async () => new ArrayBuffer(0),
      } as Response);

      // Wrapper for scheduled functions is slightly different in test-env if standard approach
      // but we can just invoke it if we export it properly or use wrap.
      // updateCitiesJsonScheduled is an exported onSchedule function.
      const wrapped = testEnv.wrap(updateCitiesJsonScheduled);
      await expect(wrapped({})).resolves.not.toThrow();
    });
  });
});
