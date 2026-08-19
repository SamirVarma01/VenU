# firestore-tests

Unit tests for `firestore.rules`, run against the real Firestore emulator (not mocks) via `@firebase/rules-unit-testing`. This is what would have caught the schools-read-permission bug and the friendships `user1ID`/`user2ID` field-name mismatch before either shipped.

## Setup

```bash
cd firestore-tests
npm install
```

Requires Java (for the emulator) — `java -version` should work. No Firebase login or real project needed; the emulator runs entirely locally against a fake project id.

## Run

```bash
npm test
```

This starts the Firestore emulator, runs `rules.test.mjs` against it with Node's built-in test runner, then tears the emulator down — one self-contained command, safe to re-run anytime `firestore.rules` changes.
