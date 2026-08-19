// Pulls upcoming music events from the Ticketmaster Discovery API near a
// school (by lat/long + radius) and writes them into the `concerts` and
// `venues` Firestore collections, matching the shape in
// mobile/src/types/models.ts.
//
// Usage:
//   npm run sync-concerts -- --school=rutgers-new-brunswick --radius=25
//
// Requires scripts/.env (TICKETMASTER_API_KEY) and
// scripts/service-account.json — see scripts/.env.example.

import { db } from './lib/firebaseAdmin.mjs';

const args = Object.fromEntries(
  process.argv.slice(2).map((arg) => {
    const [key, value] = arg.replace(/^--/, '').split('=');
    return [key, value ?? true];
  })
);

const schoolId = args.school ?? 'rutgers-new-brunswick';
const radiusMiles = Number(args.radius ?? 25);
const size = Number(args.size ?? 50);

const apiKey = process.env.TICKETMASTER_API_KEY;
if (!apiKey) {
  console.error('Missing TICKETMASTER_API_KEY — copy scripts/.env.example to scripts/.env and fill it in.');
  process.exit(1);
}

const schoolDoc = await db.collection('schools').doc(schoolId).get();
if (!schoolDoc.exists) {
  console.error(`No school "${schoolId}" found in Firestore. Run "npm run seed-schools" first.`);
  process.exit(1);
}
const school = schoolDoc.data();

const url = new URL('https://app.ticketmaster.com/discovery/v2/events.json');
url.searchParams.set('apikey', apiKey);
url.searchParams.set('latlong', `${school.latitude},${school.longitude}`);
url.searchParams.set('radius', String(radiusMiles));
url.searchParams.set('unit', 'miles');
url.searchParams.set('classificationName', 'Music');
url.searchParams.set('sort', 'date,asc');
url.searchParams.set('size', String(size));

console.log(`Fetching events within ${radiusMiles}mi of ${school.name}...`);
const response = await fetch(url);
if (!response.ok) {
  console.error(`Ticketmaster API error: ${response.status} ${await response.text()}`);
  process.exit(1);
}
const body = await response.json();
const events = body._embedded?.events ?? [];
console.log(`Got ${events.length} event(s).`);

const venues = new Map();
const concerts = [];

for (const event of events) {
  const venue = event._embedded?.venues?.[0];
  if (!venue) continue;

  if (!venues.has(venue.id)) {
    venues.set(venue.id, {
      id: venue.id,
      name: venue.name,
      address: venue.address?.line1 ?? '',
      city: venue.city?.name ?? '',
      state: venue.state?.stateCode ?? venue.state?.name ?? '',
      country: venue.country?.countryCode ?? 'USA',
      zipCode: venue.postalCode ?? null,
      latitude: parseFloat(venue.location?.latitude),
      longitude: parseFloat(venue.location?.longitude),
      capacity: null,
      imageURL: venue.images?.[0]?.url ?? null,
      source: 'ticketmaster',
      externalID: venue.id,
    });
  }

  const priceRange = event.priceRanges?.[0];
  const artistName = event._embedded?.attractions?.[0]?.name ?? event.name;
  const dateTime = event.dates?.start?.dateTime
    ? Date.parse(event.dates.start.dateTime)
    : event.dates?.start?.localDate
      ? Date.parse(event.dates.start.localDate)
      : null;
  if (!dateTime) continue;

  concerts.push({
    id: event.id,
    name: event.name,
    artistName,
    venueID: venue.id,
    venueName: venue.name,
    date: dateTime,
    imageURL: event.images?.[0]?.url ?? null,
    ticketURL: event.url ?? null,
    minPrice: priceRange?.min ?? null,
    maxPrice: priceRange?.max ?? null,
    currency: priceRange?.currency ?? 'USD',
    genre: event.classifications?.[0]?.genre?.name ?? null,
    source: 'ticketmaster',
    externalID: event.id,
    lastUpdated: Date.now(),
  });
}

const batch = db.batch();
for (const venue of venues.values()) {
  batch.set(db.collection('venues').doc(venue.id), venue, { merge: true });
}
for (const concert of concerts) {
  batch.set(db.collection('concerts').doc(concert.id), concert, { merge: true });
}
await batch.commit();

console.log(`Wrote ${venues.size} venue(s) and ${concerts.length} concert(s).`);
