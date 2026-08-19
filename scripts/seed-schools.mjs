// One-time (or re-runnable) admin seed for the `schools` collection.
// Client writes to `schools` are blocked by firestore.rules, so this has to
// go through the Admin SDK. Add more entries to SCHOOLS as you expand
// beyond Rutgers.

import { db } from './lib/firebaseAdmin.mjs';

const SCHOOLS = [
  {
    id: 'rutgers-new-brunswick',
    name: 'Rutgers University–New Brunswick',
    emailDomain: 'scarletmail.rutgers.edu',
    latitude: 40.5008,
    longitude: -74.4474,
    city: 'New Brunswick',
    state: 'NJ',
    country: 'USA',
  },
];

for (const school of SCHOOLS) {
  await db.collection('schools').doc(school.id).set(school, { merge: true });
  console.log(`Wrote schools/${school.id}`);
}

console.log(`Done — ${SCHOOLS.length} school(s) seeded.`);
