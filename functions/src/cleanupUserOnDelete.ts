import { onUserDeleted } from "firebase-functions/v2/auth";
import { getFirestore } from "firebase-admin/firestore";

/**
 * Trigger eseguito automaticamente lato server ogni volta che un utente
 * viene eliminato da Firebase Auth (via client, via Firebase Console o Admin SDK).
 * Esegue l'eliminazione a cascata ricorsiva del documento users/{uid}
 * e di tutte le sottocollezioni (come /contacts).
 */
export const cleanupUserOnDelete = onUserDeleted(async (event) => {
  const uid = event.data.uid;
  const db = getFirestore();
  const userDocRef = db.collection("users").doc(uid);

  // recursiveDelete elimina il documento e qualsiasi sottocollezione annidata
  await db.recursiveDelete(userDocRef);
});
