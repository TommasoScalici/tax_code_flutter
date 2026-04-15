import { DecodedIdToken } from "firebase-admin/auth";
import { CallableRequest } from "firebase-functions/v2/https";
import fft from "firebase-functions-test";
import { beforeAll, describe, expect, it, vi } from "vitest";

import { calculateTaxCode } from "../src/calculateTaxCode.js";

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

// Mock Firestore
const mockSet = vi.fn();
const mockGet = vi.fn();
const mockRunTransaction = vi.fn();

vi.mock("firebase-admin/firestore", () => ({
  getFirestore: () => ({
    collection: () => ({
      doc: () => ({
        get: mockGet,
        set: mockSet,
      }),
    }),
    runTransaction: mockRunTransaction,
  }),
  FieldValue: {
    serverTimestamp: () => "mock-timestamp",
  },
}));

const { mockSecretValue } = vi.hoisted(() => ({
  mockSecretValue: vi.fn().mockReturnValue("mock-api-key"),
}));

vi.mock("firebase-functions/params", () => ({
  defineSecret: () => ({
    value: mockSecretValue,
  }),
}));

describe("calculateTaxCode", () => {
  beforeAll(() => {
    vi.stubGlobal("fetch", vi.fn());
  });

  it("should throw unauthenticated error if no auth context", async () => {
    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({ data: {} } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The function must be called while authenticated.");
  });

  it("should calculate tax code correctly with valid data", async () => {
    // Mock successful transaction
    mockRunTransaction.mockImplementation(async (cb) => {
      return cb({
        get: async () => ({
          data: () => ({
            count: 0,
            date: new Date().toISOString().split("T")[0],
          }),
        }),
        set: mockSet,
      });
    });

    // Mock fetch response
    vi.mocked(global.fetch).mockResolvedValue({
      ok: true,
      json: async () => ({ tax_code: "RSSMRA80A01H501U" }),
    } as Response);

    const wrapped = testEnv.wrap(calculateTaxCode);
    const data = {
      fname: "MARIO",
      lname: "ROSSI",
      gender: "M",
      day: 1,
      month: 1,
      year: 1980,
      city: "ROMA",
      state: "RM",
    };

    const result = await wrapped({
      data,
      auth: {
        uid: "test-user",
        token: {} as unknown as DecodedIdToken,
      },
    } as unknown as CallableRequest<unknown>);

    expect(result.tax_code).toBe("RSSMRA80A01H501U");
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining("fname=MARIO"),
      expect.any(Object),
    );
  });

  it("should throw error if required data is missing", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: { fname: "Mario" }, // Missing other fields
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow(
      "The function must be called with all required birth data.",
    );
  });

  it("should handle API rate limit error (429)", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );

    vi.mocked(global.fetch).mockResolvedValue({
      ok: false,
      status: 429,
      statusText: "Too Many Requests",
      text: async () => "Rate limit exceeded",
    } as Response);

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Too many requests to the tax code service provider.");
  });

  it("should handle API internal error (500)", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );

    vi.mocked(global.fetch).mockResolvedValue({
      ok: false,
      status: 500,
      statusText: "Internal Server Error",
      text: async () => "Something went wrong",
    } as Response);

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow(
      "The tax code service provider is currently unavailable.",
    );
  });

  it("should handle API timeout", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );

    const abortError = new Error("The operation was aborted");
    abortError.name = "AbortError";
    vi.mocked(global.fetch).mockRejectedValue(abortError);

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("The request took too long.");
  });

  it("should handle unknown API error (400)", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );

    vi.mocked(global.fetch).mockResolvedValue({
      ok: false,
      status: 400,
      statusText: "Bad Request",
      text: async () => "Invalid params",
    } as Response);

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("TaxCode API error: 400");
  });

  it("should handle unexpected errors during fetch", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );

    vi.mocked(global.fetch).mockRejectedValue(new Error("Network failure"));

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Unable to reach the calculation service.");
  });

  it("should handle Firestore permission denied in rate limit check", async () => {
    mockRunTransaction.mockRejectedValue({
      code: "permission-denied",
      message: "Forbidden",
    });

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Internal service error while checking permissions.");
  });

  it("should handle generic rate limit check failure", async () => {
    mockRunTransaction.mockRejectedValue(new Error("Firebase fail"));

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Error enforcing rate limit.");
  });

  it("should handle secret access failure", async () => {
    mockRunTransaction.mockImplementation(async (cb) =>
      cb({ get: async () => ({ data: () => ({}) }), set: vi.fn() }),
    );
    mockSecretValue.mockImplementation(() => {
      throw new Error("Secret missing");
    });

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Service configuration error.");

    // Reset for other tests
    mockSecretValue.mockReturnValue("mock-api-key");
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

    const wrapped = testEnv.wrap(calculateTaxCode);
    await expect(
      wrapped({
        data: {
          fname: "M",
          lname: "R",
          gender: "M",
          day: 1,
          month: 1,
          year: 1980,
          city: "R",
          state: "R",
        },
        auth: {
          uid: "test-user",
          token: {} as unknown as DecodedIdToken,
        },
      } as unknown as CallableRequest<unknown>),
    ).rejects.toThrow("Daily limit for tax code calculations reached.");
  });
});
