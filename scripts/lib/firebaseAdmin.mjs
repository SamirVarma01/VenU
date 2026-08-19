import { readFileSync } from 'node:fs';
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH ?? './service-account.json';

let serviceAccount;
try {
  serviceAccount = JSON.parse(readFileSync(new URL(serviceAccountPath, `file://${process.cwd()}/`), 'utf8'));
} catch {
  console.error(
    `Could not read service account file at "${serviceAccountPath}".\n` +
      'Download one from Firebase Console -> Project settings -> Service accounts -> ' +
      'Generate new private key, save it as scripts/service-account.json, and copy ' +
      'scripts/.env.example to scripts/.env.'
  );
  process.exit(1);
}

const app = getApps().length
  ? getApps()[0]
  : initializeApp({ credential: cert(serviceAccount) });

export const db = getFirestore(app);
