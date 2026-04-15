import { DecodedIdToken } from "firebase-admin/auth";
import { CallableRequest } from "firebase-functions/v2/https";
import fft from "firebase-functions-test";
import { describe, expect, it, vi } from "vitest";

import { extractDataFromDocument } from "../src/extractDataFromDocument.js";

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
vi.mock("@google-cloud/vertexai", () => {
  return {
    VertexAI: class {
      getGenerativeModel() {
        return {
          generateContent: mockGenerateContent,
        };
      }
    },
    HarmCategory: {
      HARM_CATEGORY_DANGEROUS_CONTENT: "HARM_CATEGORY_DANGEROUS_CONTENT",
    },
    HarmBlockThreshold: { BLOCK_MEDIUM_AND_ABOVE: "BLOCK_MEDIUM_AND_ABOVE" },
  };
});

// Mock Firestore
const mockRunTransaction = vi.fn();
vi.mock("firebase-admin/firestore", () => ({
  getFirestore: () => ({
    collection: () => ({
      doc: () => ({}),
    }),
    runTransaction: mockRunTransaction,
  }),
  FieldValue: {
    serverTimestamp: () => "mock-timestamp",
  },
}));

describe("extractDataFromDocument", () => {
  it("should throw unauthenticated error if no auth context", async () => {
    const wrapped = testEnv.wrap(extractDataFromDocument);
    await expect(
      wrapped({
        data: { image: "base64" },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The function must be called while authenticated.");
  });

  it("should extract data correctly from Gemini response", async () => {
    // Mock rate limit pass
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({ count: 0 }) }), set: vi.fn() }),
    );

    // Mock Gemini response
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
  });

  it("should throw error if image data is missing", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );
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
  });

  it("should handle Vertex AI rate limit error (429)", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({ count: 0 }) }), set: vi.fn() }),
    );

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
  });

  it("should handle Vertex AI generic error", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({ count: 0 }) }), set: vi.fn() }),
    );

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
  });

  it("should handle Firestore permission denied in transaction", async () => {
    mockRunTransaction.mockRejectedValue({
      code: "permission-denied",
      message: "Forbidden",
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
      "Permesso negato durante il controllo dei limiti di scansione.",
    );
  });

  it("should handle generic Firestore transaction failure", async () => {
    mockRunTransaction.mockRejectedValue(new Error("Firebase common error"));

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

  it("should handle Gemini empty response", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({ count: 0 }) }), set: vi.fn() }),
    );

    mockGenerateContent.mockResolvedValue({
      response: {
        candidates: [], // Empty candidates
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
  });

  it("should handle internal rate limit exceeded", async () => {
    mockRunTransaction.mockImplementation(async (cb) => {
      return cb({
        get: async () => ({
          data: () => ({
            count: 100, // Above limit
            date: new Date().toISOString().split("T")[0],
          }),
        }),
        set: vi.fn(),
      });
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
  });
});
