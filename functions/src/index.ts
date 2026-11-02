import { initializeApp } from "firebase-admin/app";

initializeApp();

export * from "./cleanupUserOnDelete.js";
export * from "./extractDataFromDocument.js";
export * from "./updateBirthplaces.js";
