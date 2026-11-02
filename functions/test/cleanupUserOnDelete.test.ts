import fft from "firebase-functions-test";
import { beforeEach, describe, expect, it, vi } from "vitest";

const { mockRecursiveDelete, mockDocRef, mockDoc, mockCollection } = vi.hoisted(
  () => {
    const mockRecursiveDelete = vi.fn().mockResolvedValue(true);
    const mockDocRef = { id: "user-doc-ref-123" };
    const mockDoc = vi.fn().mockReturnValue(mockDocRef);
    const mockCollection = vi.fn().mockReturnValue({ doc: mockDoc });
    return { mockRecursiveDelete, mockDocRef, mockDoc, mockCollection };
  },
);

vi.mock("firebase-admin/firestore", () => ({
  getFirestore: () => ({
    collection: mockCollection,
    recursiveDelete: mockRecursiveDelete,
  }),
}));

import { cleanupUserOnDelete } from "../src/cleanupUserOnDelete.js";

const testEnv = fft();

describe("cleanupUserOnDelete", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should recursively delete the user document and nested subcollections upon user deletion", async () => {
    const wrapped = testEnv.wrap(cleanupUserOnDelete);
    const mockEvent = {
      data: {
        uid: "target-user-uid-789",
      },
    };

    await wrapped(mockEvent as unknown as Parameters<typeof wrapped>[0]);

    expect(mockCollection).toHaveBeenCalledWith("users");
    expect(mockDoc).toHaveBeenCalledWith("target-user-uid-789");
    expect(mockRecursiveDelete).toHaveBeenCalledWith(mockDocRef);
  });

  it("should propagate errors when recursiveDelete fails", async () => {
    mockRecursiveDelete.mockRejectedValueOnce(
      new Error("Firestore deletion failed"),
    );

    const wrapped = testEnv.wrap(cleanupUserOnDelete);
    const mockEvent = {
      data: {
        uid: "failing-user-uid",
      },
    };

    await expect(
      wrapped(mockEvent as unknown as Parameters<typeof wrapped>[0]),
    ).rejects.toThrow("Firestore deletion failed");
  });
});
