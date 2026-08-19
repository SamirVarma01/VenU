// Runs against the Firestore emulator (via `npm test`, which wraps this in
// `firebase emulators:exec`) and exercises firestore.rules directly —
// exactly the class of bug that shipped with the schools collection
// (read blocked on an unauthenticated onboarding screen) and with the
// original friendships rules (referenced user1ID/user2ID, fields that
// don't exist on the Friendship model — should have been requesterID/recipientID).

import { test, before, after, beforeEach } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertSucceeds, assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'venu-rules-test',
    firestore: {
      rules: readFileSync('../firestore.rules', 'utf8'),
      host: 'localhost',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

beforeEach(async () => {
  await testEnv.clearFirestore();
});

function asUser(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function asGuest() {
  return testEnv.unauthenticatedContext().firestore();
}

// Writes directly to the emulator bypassing rules — for seeding fixture
// data a test needs to already exist before exercising read/write rules.
async function seed(path, data) {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

// ---- schools: public read, no client writes ----

test('schools: unauthenticated user can read (onboarding happens pre-signup)', async () => {
  await seed('schools/rutgers-new-brunswick', { name: 'Rutgers' });
  await assertSucceeds(getDoc(doc(asGuest(), 'schools/rutgers-new-brunswick')));
});

test('schools: no one can write, even authenticated', async () => {
  await assertFails(setDoc(doc(asUser('alice'), 'schools/fake'), { name: 'Fake U' }));
});

// ---- users: read requires auth, write only your own doc ----

test('users: unauthenticated read is denied', async () => {
  await seed('users/alice', { displayName: 'Alice' });
  await assertFails(getDoc(doc(asGuest(), 'users/alice')));
});

test("users: a user can write their own doc but not someone else's", async () => {
  const db = asUser('alice');
  await assertSucceeds(setDoc(doc(db, 'users/alice'), { displayName: 'Alice' }));
  await assertFails(setDoc(doc(db, 'users/bob'), { displayName: 'Not Alice' }));
});

// ---- concerts / venues ----

test('concerts: authenticated users can read and write', async () => {
  const db = asUser('alice');
  await assertSucceeds(setDoc(doc(db, 'concerts/c1'), { name: 'Test Show' }));
  await assertSucceeds(getDoc(doc(db, 'concerts/c1')));
});

test('venues: authenticated users can read but never write', async () => {
  await seed('venues/v1', { name: 'Test Venue' });
  const db = asUser('alice');
  await assertFails(setDoc(doc(db, 'venues/v1'), { name: 'Renamed' }));
  await assertSucceeds(getDoc(doc(db, 'venues/v1')));
});

// ---- friendships: regression test for the requesterID/recipientID field-name bug ----

test('friendships: a participant (requester or recipient) can read, others cannot', async () => {
  await seed('friendships/f1', { requesterID: 'alice', recipientID: 'bob', status: 'pending' });

  await assertSucceeds(getDoc(doc(asUser('alice'), 'friendships/f1')));
  await assertSucceeds(getDoc(doc(asUser('bob'), 'friendships/f1')));
  await assertFails(getDoc(doc(asUser('carol'), 'friendships/f1')));
});

test('friendships: anyone authenticated can create a request', async () => {
  const db = asUser('alice');
  await assertSucceeds(
    setDoc(doc(db, 'friendships/f2'), { requesterID: 'alice', recipientID: 'bob', status: 'pending' })
  );
});

// ---- messages: only sender/recipient can read; only sender can create as themselves ----

test('messages: sender can create as themselves but not impersonate another sender', async () => {
  const db = asUser('alice');
  await assertSucceeds(setDoc(doc(db, 'messages/m1'), { senderID: 'alice', recipientID: 'bob', content: 'hi' }));
  await assertFails(
    setDoc(doc(db, 'messages/m2'), { senderID: 'bob', recipientID: 'alice', content: 'spoofed' })
  );
});

// ---- reviews: create requires authorID == auth.uid; only author can update/delete ----

test('reviews: anyone authenticated can create as themselves, not as someone else', async () => {
  const db = asUser('alice');
  await assertSucceeds(setDoc(doc(db, 'reviews/r1'), { authorID: 'alice', content: 'Great show' }));
  await assertFails(setDoc(doc(db, 'reviews/r2'), { authorID: 'bob', content: 'Spoofed review' }));
});

test('reviews: only the author can update their review', async () => {
  await seed('reviews/r3', { authorID: 'alice', content: 'Original' });

  await assertSucceeds(updateDoc(doc(asUser('alice'), 'reviews/r3'), { content: 'Edited' }));
  await assertFails(updateDoc(doc(asUser('bob'), 'reviews/r3'), { content: 'Hijacked' }));
});
