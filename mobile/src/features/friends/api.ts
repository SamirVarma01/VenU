// NEW — legacy-ios only had the Friendship SwiftData model, no repository.
// Stub CRUD over the `friendships` collection to give the feature a home;
// not wired into any screen yet.

import { addDoc, getDocs, query, where } from 'firebase/firestore';
import { friendshipsCollection } from '../../firebase/collections';
import type { Friendship } from '../../types/models';

export async function sendFriendRequest(requesterID: string, recipientID: string): Promise<void> {
  const now = Date.now();
  await addDoc(friendshipsCollection(), {
    id: '', // Firestore assigns the doc id; not persisted back here yet
    requesterID,
    recipientID,
    status: 'pending',
    createdAt: now,
    updatedAt: now,
  } satisfies Friendship);
}

export async function fetchFriendshipsForUser(userID: string): Promise<Friendship[]> {
  const [asRequester, asRecipient] = await Promise.all([
    getDocs(query(friendshipsCollection(), where('requesterID', '==', userID))),
    getDocs(query(friendshipsCollection(), where('recipientID', '==', userID))),
  ]);
  return [...asRequester.docs, ...asRecipient.docs].map((d) => d.data());
}
