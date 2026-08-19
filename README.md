# VenU 🎵

**Find concert buddies at your college**

VenU is a social networking app for college students to discover concerts, connect with fellow music lovers, and find friends to attend events together — for iOS and Android.

## Repo layout

- **[`mobile/`](mobile)** — the active app: React Native + Expo (TypeScript), targeting iOS and Android from one codebase. See [`mobile/README.md`](mobile/README.md) for setup/run instructions.
- **[`scripts/`](scripts)** — admin tooling (Firebase Admin SDK) for seeding `schools` and syncing real concert/venue data from Ticketmaster, since both collections deliberately block client writes. See [`scripts/README.md`](scripts/README.md).
- **[`legacy-ios/`](legacy-ios)** — the original native Swift/SwiftUI/SwiftData iOS-only prototype. Archived, not built or maintained, kept as schema/logic reference (see [`legacy-ios/README.md`](legacy-ios/README.md)).
- **`firebase.json`, `firestore.rules`, `firestore.indexes.json`, `.firebaserc`** — shared Firebase project config (project: `venyou-9ef84`), used by both the mobile app and, eventually, Cloud Functions.

## Feature status

Four features are being validated first. None are fully built end-to-end yet — this reflects an audit of the legacy Swift code, ported forward to the new app's structure:

| Feature | Status |
|---|---|
| **Concert discovery near your college** | Partial. Firestore-backed fetch of upcoming concerts works (`mobile/src/features/concerts/api.ts`, `app/(tabs)/concerts/`), and `scripts/sync-concerts.mjs` pulls real events from Ticketmaster (already geo-filtered by Ticketmaster's own `latlong`+`radius` search) into Firestore. Still missing: the app itself doesn't yet do its own "near your college" query against stored data — it only shows what was last synced for whichever school you ran the script against. |
| **Friends** | Not built. Data model and Firestore rules exist (`mobile/src/types/models.ts`, `firestore.rules`); `mobile/src/features/friends/api.ts` has stub create/list functions not wired into any screen. |
| **Messaging** | Not built. Same state as Friends — model + rules exist, `mobile/src/features/messaging/api.ts` has stubs, no UI. |
| **Concert review / post feed** | Not built. This is entirely new — no equivalent existed in the Swift prototype. Model, Firestore rules, and stub API exist (`mobile/src/features/reviews/api.ts`); no UI. |

Auth (sign up with `.edu`/`.ac.uk`/`.ac.in` email, school-domain matching, email verification) is ported and functional in `mobile/app/(auth)/`.

## Firebase setup

1. Reuse the existing Firebase project (`venyou-9ef84`) or point `.firebaserc` at your own.
2. In the Firebase Console, enable **Authentication → Email/Password** and create a **Firestore Database**.
3. Deploy security rules: `firebase deploy --only firestore:rules` (rules live in [`firestore.rules`](firestore.rules)).
4. Copy `mobile/.env.example` to `mobile/.env` and fill in your web app config from Project Settings → General → Your apps.
5. Seed at least one school and sync real concert data using [`scripts/`](scripts) — `npm run seed-schools` then `npm run sync-concerts`.

## Development

- Follow the mobile app's own conventions — see [`mobile/README.md`](mobile/README.md).
- Firestore field names are intentionally kept identical between `legacy-ios` and `mobile` so existing data/rules don't need to change.

## Author

Samir Varma
