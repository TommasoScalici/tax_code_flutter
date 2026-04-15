import { execSync } from "child_process";
import { DecodedIdToken } from "firebase-admin/auth";
import { CallableRequest } from "firebase-functions/v2/https";
import { ScheduledEvent } from "firebase-functions/v2/scheduler";
import fft from "firebase-functions-test";
import * as fs from "fs";
import { beforeEach, describe, expect, it, vi } from "vitest";

import {
  downloadAndParseBirthplaceData,
  updateBirthplaces,
  updateBirthplacesScheduled,
} from "../src/updateBirthplaces";

const testEnv = fft();

// Mock fetch
global.fetch = vi.fn();

// Mock child_process and fs
vi.mock("child_process", () => ({
  execSync: vi.fn(),
}));

vi.mock("fs", () => ({
  writeFileSync: vi.fn(),
  unlinkSync: vi.fn(),
}));

// Mock firebase-admin
const mockSave = vi.fn().mockResolvedValue(true);
const mockMakePublic = vi.fn().mockResolvedValue(true);
const mockExists = vi.fn().mockResolvedValue([true]);
vi.mock("firebase-admin/storage", () => ({
  getStorage: () => ({
    bucket: () => ({
      file: () => ({
        save: mockSave,
        makePublic: mockMakePublic,
        exists: mockExists,
      }),
    }),
  }),
}));

// Mock logger to silence verbose output during tests
vi.mock("firebase-functions", async (importOriginal) => {
  const actual = await importOriginal<typeof import("firebase-functions")>();
  return {
    ...actual,
    logger: {
      ...actual.logger,
      info: vi.fn(),
      error: vi.fn(),
      warn: vi.fn(),
      debug: vi.fn(),
    },
  };
});

describe("updateBirthplaces", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    // Default fetch mocks
    vi.mocked(global.fetch).mockResolvedValue({
      ok: true,
      json: async () => ({ resultset: [] }),
      arrayBuffer: async () => new ArrayBuffer(0),
    } as Response);
  });

  describe("updateBirthplaces core logic", () => {
    it("should succeed and perform full ingestion if admin", async () => {
      // 1. Mock Italian Municipalities JSON response
      vi.mocked(global.fetch).mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          resultset: [
            { COMUNE: "Roma", SIGLA_AUTOMOBILISTICA: "RM" },
            { COMUNE: "Milano", SIGLA_AUTOMOBILISTICA: "MI" },
          ],
        }),
      } as Response);

      // 2. Mock Foreign Countries ZIP response
      vi.mocked(global.fetch).mockResolvedValueOnce({
        ok: true,
        arrayBuffer: async () => new ArrayBuffer(8),
      } as Response);

      // 3. Mock unzip -p output (robust method using wildcard)
      const mockCsv = "Denominazione IT;Dummy\nFrancia;X\nGermania;Y\n";
      vi.mocked(execSync).mockReturnValueOnce(Buffer.from(mockCsv));

      const wrapped = testEnv.wrap(updateBirthplaces);
      const result = await wrapped({
        auth: {
          uid: "test-admin",
          token: { admin: true } as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<void>);

      expect(result.success).toBe(true);
      expect(result.count).toBe(4); // 2 cities + 2 countries

      expect(fs.writeFileSync).toHaveBeenCalled();
      expect(fs.unlinkSync).toHaveBeenCalled();
      expect(mockSave).toHaveBeenCalled();

      // Verify "EE" state for foreign countries
      const savedData = JSON.parse(mockSave.mock.calls[0][0]);
      const francia = savedData.find(
        (b: { name: string }) => b.name === "FRANCIA",
      );
      expect(francia.state).toBe("EE");
      const roma = savedData.find((b: { name: string }) => b.name === "ROMA");
      expect(roma.state).toBe("RM");
    });

    it("should handle foreign fetch failure gracefully", async () => {
      vi.mocked(global.fetch).mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          resultset: [{ COMUNE: "Roma", SIGLA_AUTOMOBILISTICA: "RM" }],
        }),
      } as Response);

      vi.mocked(global.fetch).mockResolvedValueOnce({
        ok: false,
        statusText: "Not Found",
      } as Response);

      const count = await downloadAndParseBirthplaceData();
      expect(count).toBe(1); // Only Roma
    });

    it("should throw unauthenticated error if no auth context", async () => {
      const wrapped = testEnv.wrap(updateBirthplaces);
      await expect(
        wrapped({} as unknown as CallableRequest<void>),
      ).rejects.toThrow("Authentication required");
    });

    it("should throw permission denied error if not admin and file exists", async () => {
      mockExists.mockResolvedValueOnce([true]);
      const wrapped = testEnv.wrap(updateBirthplaces);
      await expect(
        wrapped({
          auth: {
            uid: "test-user",
            token: { admin: false } as unknown as DecodedIdToken,
          },
        } as unknown as CallableRequest<void>),
      ).rejects.toThrow("Admin privileges required");
    });

    it("should allow authenticated non-admin to update if file is missing", async () => {
      mockExists.mockResolvedValueOnce([false]);

      // Mock successful fetch for this test
      vi.mocked(global.fetch).mockResolvedValue({
        ok: true,
        json: async () => ({ resultset: [] }),
        arrayBuffer: async () => new ArrayBuffer(0),
      } as Response);

      const wrapped = testEnv.wrap(updateBirthplaces);
      const result = await wrapped({
        auth: {
          uid: "test-user",
          token: { admin: false } as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<void>);

      expect(result.success).toBe(true);
      expect(mockSave).toHaveBeenCalled();
    });
  });

  describe("updateBirthplacesScheduled", () => {
    it("should call downloadAndParseBirthplaceData", async () => {
      // @ts-expect-error - firebase-functions-test v2 types
      const wrapped = testEnv.wrap(updateBirthplacesScheduled);
      await expect(
        wrapped({} as unknown as ScheduledEvent),
      ).resolves.not.toThrow();
    });
  });
});
