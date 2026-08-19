# VenU mobile

React Native (Expo, TypeScript) app for iOS + Android. See the [repo root README](../README.md) for the overall project layout and feature status.

## Setup

1. Install dependencies:

   ```bash
   npm install
   ```

2. Configure Firebase: copy `.env.example` to `.env` and fill in your Firebase web app config (Firebase Console → Project Settings → General → Your apps).

3. Start the dev server:

   ```bash
   npx expo start
   ```

   Scan the QR code with [Expo Go](https://expo.dev/go) on your phone (iOS or Android) — no native build needed for this stage. Press `a` / `i` in the terminal for an Android emulator / iOS simulator if you have one set up.

## Structure

```
app/                    # Expo Router routes (file-based)
  (auth)/                 # unauthenticated: school-select -> sign-up -> verify-email, or sign-in
  (tabs)/                 # authenticated tab bar — one folder per feature
    concerts/                # 1. concert discovery near your college
    friends/                 # 2. friends
    messages/                # 3. messaging
    feed/                    # 4. review/post feed
    profile/
src/
  firebase/              # Firebase app/auth/firestore init + typed collection refs
  types/models.ts        # TS types mirroring the Firestore schema
  features/<name>/api.ts # Firestore reads/writes per feature, kept separate from screens
```

Each feature's `api.ts` is the place to build out real functionality — screens under `app/(tabs)/` currently just render placeholders and call the read functions that exist. See the root README's feature status table for what's implemented vs. stubbed.
