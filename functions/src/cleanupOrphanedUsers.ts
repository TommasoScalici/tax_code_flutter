import { initializeApp, getApps } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";

// Inizializza l'app se non già inizializzata
if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();
const auth = getAuth();

interface CleanupReport {
  scanned: number;
  validUsers: number;
  orphanedAuthNotFound: string[];
  emptyGuestRecords: string[];
  deleted: number;
  dryRun: boolean;
}

/**
 * Pulisce i documenti utente orfani o vuoti in Firestore:
 * 1. Documenti il cui UID non esiste più in Firebase Auth.
 * 2. Documenti con dati anagrafici vuoti (ospiti) e nessuna sottocollezione contatti.
 *
 * @param dryRun Se true (default), simula la pulizia senza cancellare nulla.
 */
export async function cleanupOrphanedUsers(dryRun = true): Promise<CleanupReport> {
  console.log(`[CLEANUP] Avvio scansione utenti Firestore... (dryRun: ${dryRun})`);

  const usersCollection = db.collection("users");
  const snapshot = await usersCollection.get();

  const report: CleanupReport = {
    scanned: snapshot.size,
    validUsers: 0,
    orphanedAuthNotFound: [],
    emptyGuestRecords: [],
    deleted: 0,
    dryRun,
  };

  for (const doc of snapshot.docs) {
    const uid = doc.id;
    const data = doc.data();

    let authUserExists = false;
    try {
      await auth.getUser(uid);
      authUserExists = true;
      report.validUsers++;
    } catch (err: any) {
      if (err.code === "auth/user-not-found") {
        authUserExists = false;
      } else {
        console.error(`Errore verifica Auth per UID ${uid}:`, err);
        continue;
      }
    }

    // Se l'utente NON esiste più in Firebase Auth
    if (!authUserExists) {
      report.orphanedAuthNotFound.push(uid);
      console.log(`[ORPHAN] Utente non trovato in Auth: ${uid}`);

      if (!dryRun) {
        await db.recursiveDelete(doc.ref);
        report.deleted++;
      }
      continue;
    }

    // Se l'utente esiste ma è un guest con campi vuoti e 0 contatti
    const isFieldsEmpty =
      (!data.email || data.email === "") &&
      (!data.displayName || data.displayName === "");

    if (isFieldsEmpty) {
      const contactsSnap = await doc.ref.collection("contacts").limit(1).get();
      if (contactsSnap.empty) {
        report.emptyGuestRecords.push(uid);
        console.log(`[EMPTY GUEST] Ospite senza contatti né dati: ${uid}`);

        if (!dryRun) {
          await db.recursiveDelete(doc.ref);
          report.deleted++;
        }
      }
    }
  }

  console.log("[REPORT COMPLETO]", report);
  return report;
}

// Esecuzione diretta via riga di comando: node cleanup_orphaned_users.js [--apply]
const isApply = process.argv.includes("--apply");
cleanupOrphanedUsers(!isApply).catch(console.error);
