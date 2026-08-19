# scripts

Admin-only tooling for seeding/syncing data that the app itself isn't allowed to write (see `firestore.rules` — `schools` and `venues` block client writes on purpose). Runs with the Firebase Admin SDK, which bypasses those rules, so it's kept separate from `mobile/` rather than mixed into the app's dependencies.

## Setup

1. `cd scripts && npm install`
2. Get a service account key: Firebase Console → gear icon → **Project settings → Service accounts** → **Generate new private key**. Save the downloaded file as `scripts/service-account.json` (gitignored — never commit this, it's full admin access to your Firebase project).
3. Get a Ticketmaster API key: [developer.ticketmaster.com](https://developer.ticketmaster.com/) → sign up → create an app → copy the **Consumer Key**.
4. Copy `.env.example` to `.env` and fill in `TICKETMASTER_API_KEY`.

## Usage

```bash
npm run seed-schools                                        # writes the schools/ collection (currently: Rutgers New Brunswick only)
npm run sync-concerts -- --school=rutgers-new-brunswick --radius=25   # pulls real events from Ticketmaster into concerts/ + venues/
```

`sync-concerts` reads the school's lat/long from Firestore (so run `seed-schools` first), queries Ticketmaster for music events within `--radius` miles, and upserts them. Re-running it is safe — writes use `merge: true` keyed by Ticketmaster's own IDs.
