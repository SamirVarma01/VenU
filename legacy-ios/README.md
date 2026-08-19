# legacy-ios (archived)

This is the original native Swift/SwiftUI/SwiftData prototype of VenU. It has been superseded by the React Native app in [`mobile/`](../mobile), which targets both iOS and Android.

This code is **not maintained or built** going forward. It's kept around because the Firestore schema, field names, and Firebase Auth flow (email verification, `.edu` domain validation) it implements are a useful reference when porting logic to `mobile/`.

## What was here

- SwiftData models: `User`, `School`, `Concert`, `Venue`, `ConcertAttendance`, `Friendship`, `Message` — each with `toFirestore()`/`fromFirestore()` mirroring the Firestore document shape.
- `ServicesFirebaseManager.swift` — Firebase Auth wrapper (sign up/in/out, password reset, email verification, college-domain validation).
- `Repositories*.swift` — Firestore data access for Users, Schools, Concerts.
- `ViewModels*.swift` / `Views*.swift` — SwiftUI screens for onboarding, concert browsing, and user profile.

At the time of archiving, only concert discovery had a working Firestore-backed repository and UI (still missing a geo-query for "concerts near your school"). Friends and messaging were data-model-only, with no repository/UI. Reviews/posts didn't exist. See the root `README.md` for the current feature status.
