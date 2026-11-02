import { beforeEach, describe, expect, it, vi } from "vitest";

const { mockGetUser, mockRecursiveDelete, mockGetUsersSnapshot } = vi.hoisted(
  () => ({
    mockGetUser: vi.fn(),
    mockRecursiveDelete: vi.fn().mockResolvedValue(true),
    mockGetUsersSnapshot: vi.fn(),
  }),
);

vi.mock("firebase-admin/app", () => ({
  initializeApp: vi.fn(),
  getApps: vi.fn().mockReturnValue([{ name: "[DEFAULT]" }]),
}));

vi.mock("firebase-admin/auth", () => ({
  getAuth: () => ({
    getUser: mockGetUser,
  }),
}));

vi.mock("firebase-admin/firestore", () => ({
  getFirestore: () => ({
    collection: (collName: string) => {
      if (collName === "users") {
        return {
          get: mockGetUsersSnapshot,
        };
      }
      return {};
    },
    recursiveDelete: mockRecursiveDelete,
  }),
}));

import { cleanupOrphanedUsers } from "../src/cleanupOrphanedUsers.js";

describe("cleanupOrphanedUsers", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  function createMockDoc({
    uid,
    email = "",
    displayName = "",
    hasContacts = false,
  }: {
    uid: string;
    email?: string;
    displayName?: string;
    hasContacts?: boolean;
  }) {
    const mockContactsGet = vi.fn().mockResolvedValue({
      empty: !hasContacts,
    });
    const mockRef = {
      id: uid,
      collection: (subColl: string) => {
        if (subColl === "contacts") {
          return {
            limit: () => ({
              get: mockContactsGet,
            }),
          };
        }
        return {};
      },
    };

    return {
      id: uid,
      data: () => ({ email, displayName }),
      ref: mockRef,
    };
  }

  it("should detect orphaned users whose Auth record does not exist without deleting in dryRun mode", async () => {
    const orphanDoc = createMockDoc({ uid: "orphan-uid-1" });
    mockGetUsersSnapshot.mockResolvedValueOnce({
      size: 1,
      docs: [orphanDoc],
    });

    const notFoundError = new Error("User not found");
    (notFoundError as unknown as { code: string }).code = "auth/user-not-found";
    mockGetUser.mockRejectedValueOnce(notFoundError);

    const report = await cleanupOrphanedUsers(true);

    expect(report.scanned).toBe(1);
    expect(report.validUsers).toBe(0);
    expect(report.orphanedAuthNotFound).toEqual(["orphan-uid-1"]);
    expect(report.emptyGuestRecords).toHaveLength(0);
    expect(report.deleted).toBe(0);
    expect(report.dryRun).toBe(true);
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });

  it("should delete orphaned users when dryRun is false", async () => {
    const orphanDoc = createMockDoc({ uid: "orphan-uid-2" });
    mockGetUsersSnapshot.mockResolvedValueOnce({
      size: 1,
      docs: [orphanDoc],
    });

    const notFoundError = new Error("User not found");
    (notFoundError as unknown as { code: string }).code = "auth/user-not-found";
    mockGetUser.mockRejectedValueOnce(notFoundError);

    const report = await cleanupOrphanedUsers(false);

    expect(report.scanned).toBe(1);
    expect(report.orphanedAuthNotFound).toEqual(["orphan-uid-2"]);
    expect(report.deleted).toBe(1);
    expect(report.dryRun).toBe(false);
    expect(mockRecursiveDelete).toHaveBeenCalledWith(orphanDoc.ref);
  });

  it("should detect empty guest records with no contacts and delete them when dryRun is false", async () => {
    const emptyGuestDoc = createMockDoc({
      uid: "guest-empty-uid",
      email: "",
      displayName: "",
      hasContacts: false,
    });
    mockGetUsersSnapshot.mockResolvedValueOnce({
      size: 1,
      docs: [emptyGuestDoc],
    });

    mockGetUser.mockResolvedValueOnce({ uid: "guest-empty-uid" });

    const report = await cleanupOrphanedUsers(false);

    expect(report.scanned).toBe(1);
    expect(report.validUsers).toBe(1);
    expect(report.orphanedAuthNotFound).toHaveLength(0);
    expect(report.emptyGuestRecords).toEqual(["guest-empty-uid"]);
    expect(report.deleted).toBe(1);
    expect(mockRecursiveDelete).toHaveBeenCalledWith(emptyGuestDoc.ref);
  });

  it("should not delete guest records if they contain contacts", async () => {
    const guestWithContactsDoc = createMockDoc({
      uid: "guest-with-contacts",
      email: "",
      displayName: "",
      hasContacts: true,
    });
    mockGetUsersSnapshot.mockResolvedValueOnce({
      size: 1,
      docs: [guestWithContactsDoc],
    });

    mockGetUser.mockResolvedValueOnce({ uid: "guest-with-contacts" });

    const report = await cleanupOrphanedUsers(false);

    expect(report.scanned).toBe(1);
    expect(report.validUsers).toBe(1);
    expect(report.emptyGuestRecords).toHaveLength(0);
    expect(report.deleted).toBe(0);
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });

  it("should preserve fully authenticated users with email or displayName", async () => {
    const normalUserDoc = createMockDoc({
      uid: "valid-user-123",
      email: "mario.rossi@example.com",
      displayName: "Mario Rossi",
    });
    mockGetUsersSnapshot.mockResolvedValueOnce({
      size: 1,
      docs: [normalUserDoc],
    });

    mockGetUser.mockResolvedValueOnce({
      uid: "valid-user-123",
      email: "mario.rossi@example.com",
    });

    const report = await cleanupOrphanedUsers(false);

    expect(report.scanned).toBe(1);
    expect(report.validUsers).toBe(1);
    expect(report.orphanedAuthNotFound).toHaveLength(0);
    expect(report.emptyGuestRecords).toHaveLength(0);
    expect(report.deleted).toBe(0);
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });

  it("should gracefully handle unexpected errors when querying Firebase Auth", async () => {
    const errorDoc = createMockDoc({ uid: "error-uid" });
    mockGetUsersSnapshot.mockResolvedValueOnce({
      size: 1,
      docs: [errorDoc],
    });

    const unexpectedError = new Error("Firebase Auth service unavailable");
    mockGetUser.mockRejectedValueOnce(unexpectedError);

    const report = await cleanupOrphanedUsers(false);

    expect(report.scanned).toBe(1);
    expect(report.validUsers).toBe(0);
    expect(report.orphanedAuthNotFound).toHaveLength(0);
    expect(report.deleted).toBe(0);
    expect(mockRecursiveDelete).not.toHaveBeenCalled();
  });
});
