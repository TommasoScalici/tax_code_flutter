import { DecodedIdToken } from "firebase-admin/auth";
import { CallableRequest } from "firebase-functions/v2/https";
import { beforeEach, describe, expect, it, vi } from "vitest";

import {
  cleanJsonResponseText,
  extractDataFromDocument,
  normalizeExtractedData,
  resetCachedAiConfig,
} from "../src/extractDataFromDocument.js";

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

// Mock Google Gen AI SDK
const mockGenerateContent = vi.fn();
vi.mock("@google/genai", () => {
  return {
    GoogleGenAI: class {
      models = {
        generateContent: mockGenerateContent,
      };
    },
    HarmCategory: {
      HARM_CATEGORY_DANGEROUS_CONTENT: "HARM_CATEGORY_DANGEROUS_CONTENT",
    },
    HarmBlockThreshold: { BLOCK_MEDIUM_AND_ABOVE: "BLOCK_MEDIUM_AND_ABOVE" },
    ThinkingLevel: {
      MINIMAL: "MINIMAL",
      LOW: "LOW",
      MEDIUM: "MEDIUM",
      HIGH: "HIGH",
    },
    Type: {
      STRING: "STRING",
      NUMBER: "NUMBER",
      INTEGER: "INTEGER",
      BOOLEAN: "BOOLEAN",
      ARRAY: "ARRAY",
      OBJECT: "OBJECT",
    },
  };
});

// Mock Firestore
const mockDocGet = vi.fn();
const mockRunTransaction = vi.fn();
vi.mock("firebase-admin/firestore", () => ({
  getFirestore: () => ({
    collection: (collName: string) => ({
      doc: (docName: string) => ({
        get: () => mockDocGet(collName, docName),
      }),
    }),
    runTransaction: mockRunTransaction,
  }),
  FieldValue: {
    serverTimestamp: () => "mock-timestamp",
  },
}));

describe("extractDataFromDocument", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    resetCachedAiConfig();

    mockDocGet.mockImplementation(async (coll: string) => {
      if (coll === "systemConfig") {
        return { exists: false, data: () => ({}) };
      }
      return {
        exists: true,
        data: () => ({
          count: 0,
          date: new Date().toISOString().split("T")[0],
        }),
      };
    });

    mockRunTransaction.mockImplementation(async (cb: (t: unknown) => unknown) =>
      cb({
        get: async () => ({
          data: () => ({
            count: 0,
            date: new Date().toISOString().split("T")[0],
          }),
        }),
        set: vi.fn(),
      }),
    );
  });

  it("should throw unauthenticated error if no auth context", async () => {
    await expect(
      extractDataFromDocument.run({
        data: { image: "base64" },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The function must be called while authenticated.");
  });

  it("should extract data correctly and increment rate limit after success", async () => {
    mockGenerateContent.mockResolvedValue({
      text: JSON.stringify({
        firstName: "MARIO",
        lastName: "ROSSI",
        gender: "M",
        birthPlace: { name: "ROMA", state: "RM" },
        birthDate: "1980-01-01",
      }),
    });

    const result = await extractDataFromDocument.run({
      data: { image: "valid-base64-string" },
      auth: {
        uid: "test-user",
        token: {} as unknown as DecodedIdToken,
      },
    } as unknown as CallableRequest<unknown>);

    expect(result.firstName).toBe("MARIO");
    expect(result.birthPlace.name).toBe("ROMA");
    expect(mockGenerateContent).toHaveBeenCalled();
    // Rate limit increment should be committed on success
    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
  });

  it("should throw error if image data is missing", async () => {
    await expect(
      extractDataFromDocument.run({
        data: {}, // No image
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The function must be called with an 'image' argument.");
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  it("should handle Vertex AI rate limit error (429) without consuming user quota", async () => {
    mockGenerateContent.mockRejectedValue({
      status: 429,
      message: "Quota exceeded",
    });

    await expect(
      extractDataFromDocument.run({
        data: { image: "valid-base64-string" },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow(
      "The service is currently overloaded. Please try again later.",
    );

    // CRITICAL: User quota must NOT be incremented on error
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  it("should handle Vertex AI generic error without consuming user quota", async () => {
    mockGenerateContent.mockRejectedValue(new Error("Something went wrong"));

    await expect(
      extractDataFromDocument.run({
        data: { image: "valid-base64-string" },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The function encountered an error during processing.");

    // User quota must NOT be incremented on error
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  it("should handle Firestore permission denied in pre-check", async () => {
    mockDocGet.mockImplementation(async (coll: string) => {
      if (coll === "rateLimits") {
        const error = new Error("Forbidden") as Error & { code: string };
        error.code = "permission-denied";
        throw error;
      }
      return { exists: false, data: () => ({}) };
    });

    await expect(
      extractDataFromDocument.run({
        data: { image: "base64" },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Permission denied while checking scan limits.");
  });

  it("should handle generic Firestore pre-check failure", async () => {
    mockDocGet.mockImplementation(async (coll: string) => {
      if (coll === "rateLimits") {
        throw new Error("Firebase common error");
      }
      return { exists: false, data: () => ({}) };
    });

    await expect(
      extractDataFromDocument.run({
        data: { image: "base64" },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Error enforcing rate limit.");
  });

  it("should handle Gemini empty response without consuming quota", async () => {
    mockGenerateContent.mockResolvedValue({
      candidates: [],
    });

    await expect(
      extractDataFromDocument.run({
        data: { image: "base64" },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Failed to extract data from the document.");

    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  it("should handle internal rate limit exceeded in pre-check", async () => {
    mockDocGet.mockImplementation(async (coll: string) => {
      if (coll === "rateLimits") {
        return {
          exists: true,
          data: () => ({
            count: 100, // Above limit
            date: new Date().toISOString().split("T")[0],
          }),
        };
      }
      return { exists: false, data: () => ({}) };
    });

    await expect(
      extractDataFromDocument.run({
        data: { image: "base64" },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow(
      "You have exceeded your daily limit for document processing.",
    );

    expect(mockGenerateContent).not.toHaveBeenCalled();
    expect(mockRunTransaction).not.toHaveBeenCalled();
  });

  it("should fallback to fallbackModel when primary model fails and succeed", async () => {
    // First call with primary model fails, second with fallback succeeds
    mockGenerateContent
      .mockRejectedValueOnce(new Error("Model not found in region"))
      .mockResolvedValueOnce({
        text: JSON.stringify({
          firstName: "GIULIA",
          lastName: "BIANCHI",
          gender: "F",
          birthPlace: { name: "MILANO", state: "MI" },
          birthDate: "1992-05-12",
        }),
      });

    const result = await extractDataFromDocument.run({
      data: { image: "valid-base64-string" },
      auth: {
        uid: "test-user",
        token: {} as unknown as DecodedIdToken,
      },
    } as unknown as CallableRequest<unknown>);

    expect(result.firstName).toBe("GIULIA");
    expect(result.gender).toBe("F");
    expect(mockGenerateContent).toHaveBeenCalledTimes(2);
    expect(mockRunTransaction).toHaveBeenCalledTimes(1);
  });

  it("should load custom AI configuration from Firestore systemConfig/ai", async () => {
    mockDocGet.mockImplementation(async (coll: string) => {
      if (coll === "systemConfig") {
        return {
          exists: true,
          data: () => ({
            model: "custom-gemini-model",
            fallbackModel: "custom-fallback-model",
            thinkingLevel: "medium",
            maxOutputTokens: 1024,
          }),
        };
      }
      return {
        exists: true,
        data: () => ({
          count: 0,
          date: new Date().toISOString().split("T")[0],
        }),
      };
    });

    mockGenerateContent.mockResolvedValue({
      text: JSON.stringify({
        firstName: "LUCA",
        lastName: "VERDI",
        gender: "M",
        birthPlace: { name: "NAPOLI", state: "NA" },
        birthDate: "1995-03-20",
      }),
    });

    await extractDataFromDocument.run({
      data: { image: "valid-base64-string" },
      auth: {
        uid: "test-user",
        token: {} as unknown as DecodedIdToken,
      },
    } as unknown as CallableRequest<unknown>);

    expect(mockGenerateContent).toHaveBeenCalledWith(
      expect.objectContaining({
        model: "custom-gemini-model",
        config: expect.objectContaining({
          thinkingConfig: { thinkingLevel: "MEDIUM" },
          maxOutputTokens: 1024,
        }),
      }),
    );
  });

  describe("cleanJsonResponseText", () => {
    it("should extract JSON from markdown fences with json language identifier", () => {
      const markdown = '```json\n{"firstName":"MARIO"}\n```';
      expect(cleanJsonResponseText(markdown)).toBe('{"firstName":"MARIO"}');
    });

    it("should extract JSON from markdown fences without language identifier", () => {
      const markdown = '```\n{"firstName":"MARIO"}\n```';
      expect(cleanJsonResponseText(markdown)).toBe('{"firstName":"MARIO"}');
    });

    it("should trim and return plain JSON when no fences are present", () => {
      const plain = '  {"firstName":"MARIO"}  ';
      expect(cleanJsonResponseText(plain)).toBe('{"firstName":"MARIO"}');
    });
  });

  describe("normalizeExtractedData", () => {
    it("should normalize valid lowercase gender and whitespace", () => {
      const normalized = normalizeExtractedData({
        firstName: " Mario ",
        lastName: " Rossi ",
        gender: "m",
        birthDate: "1990-05-15",
        birthPlace: {
          name: " Roma ",
          state: "rm",
        },
      });

      expect(normalized).toEqual({
        firstName: "Mario",
        lastName: "Rossi",
        gender: "M",
        birthDate: "1990-05-15",
        birthPlace: {
          name: "Roma",
          state: "RM",
        },
      });
    });

    it("should convert DD/MM/YYYY dates to ISO YYYY-MM-DD", () => {
      const normalized = normalizeExtractedData({
        birthDate: "15/05/1990",
      });
      expect(normalized.birthDate).toBe("1990-05-15");
    });

    it("should convert DD-MM-YYYY dates to ISO YYYY-MM-DD", () => {
      const normalized = normalizeExtractedData({
        birthDate: "01-02-1985",
      });
      expect(normalized.birthDate).toBe("1985-02-01");
    });

    it("should set gender to null if unrecognized value", () => {
      const normalized = normalizeExtractedData({
        gender: "UNKNOWN",
      });
      expect(normalized.gender).toBeNull();
    });

    it("should handle empty or whitespace-only names by setting null", () => {
      const normalized = normalizeExtractedData({
        firstName: "   ",
        lastName: "",
      });
      expect(normalized.firstName).toBeNull();
      expect(normalized.lastName).toBeNull();
    });
  });
});
