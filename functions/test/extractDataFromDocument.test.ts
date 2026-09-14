import { DecodedIdToken } from "firebase-admin/auth";
import { CallableRequest } from "firebase-functions/v2/https";
import fft from "firebase-functions-test";
import { beforeEach, describe, expect, it, vi } from "vitest";

import {
  extractDataFromDocument,
  resetCachedAiConfig,
} from "../src/extractDataFromDocument.js";

const testEnv = fft();

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

// Mock Vertex AI
const mockGenerateContent = vi.fn();
const mockGetGenerativeModel = vi.fn();
vi.mock("@google-cloud/vertexai", () => {
  return {
    VertexAI: class {
      getGenerativeModel(args: unknown) {
        mockGetGenerativeModel(args);
        return {
          generateContent: mockGenerateContent,
        };
      }
    },
    HarmCategory: {
      HARM_CATEGORY_DANGEROUS_CONTENT: "HARM_CATEGORY_DANGEROUS_CONTENT",
    },
    HarmBlockThreshold: { BLOCK_MEDIUM_AND_ABOVE: "BLOCK_MEDIUM_AND_ABOVE" },
    SchemaType: {
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
    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
        data: { image: "base64" },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The function must be called while authenticated.");
  });

  it("should extract data correctly and increment rate limit after success", async () => {
    mockGenerateContent.mockResolvedValue({
      response: {
        candidates: [
          {
            content: {
              parts: [
                {
                  text: JSON.stringify({
                    firstName: "MARIO",
                    lastName: "ROSSI",
                    gender: "M",
                    birthPlace: { name: "ROMA", state: "RM" },
                    birthDate: "1980-01-01",
                  }),
                },
              ],
            },
          },
        ],
      },
    });

    const wrapped = testEnv.wrap(extractDataFromDocument);
    const result = await wrapped({
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
    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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
      response: {
        candidates: [],
      },
    });

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
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
        response: {
          candidates: [
            {
              content: {
                parts: [
                  {
                    text: JSON.stringify({
                      firstName: "GIULIA",
                      lastName: "BIANCHI",
                      gender: "F",
                      birthPlace: { name: "MILANO", state: "MI" },
                      birthDate: "1992-05-12",
                    }),
                  },
                ],
              },
            },
          ],
        },
      });

    const wrapped = testEnv.wrap(extractDataFromDocument);
    const result = await wrapped({
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
            temperature: 0.05,
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
      response: {
        candidates: [
          {
            content: {
              parts: [
                {
                  text: JSON.stringify({
                    firstName: "LUCA",
                    lastName: "VERDI",
                    gender: "M",
                    birthPlace: { name: "NAPOLI", state: "NA" },
                    birthDate: "1995-03-20",
                  }),
                },
              ],
            },
          },
        ],
      },
    });

    const wrapped = testEnv.wrap(extractDataFromDocument);
    await wrapped({
      data: { image: "valid-base64-string" },
      auth: {
        uid: "test-user",
        token: {} as unknown as DecodedIdToken,
      },
    } as unknown as CallableRequest<unknown>);

    expect(mockGetGenerativeModel).toHaveBeenCalledWith(
      expect.objectContaining({
        model: "custom-gemini-model",
        generationConfig: expect.objectContaining({
          temperature: 0.05,
          maxOutputTokens: 1024,
        }),
      }),
    );
  });
});
