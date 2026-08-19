// NEW — no equivalent existed in legacy-ios at all. Stub CRUD over a new
// `reviews` collection (added to firestore.rules) backing the concert
// review/post feed feature; not wired into any screen yet.

import { addDoc, getDocs, limit, orderBy, query, where } from 'firebase/firestore';
import { reviewsCollection } from '../../firebase/collections';
import type { Review } from '../../types/models';

export async function postReview(review: Omit<Review, 'id' | 'createdAt'>): Promise<void> {
  await addDoc(reviewsCollection(), {
    ...review,
    id: '',
    createdAt: Date.now(),
  } satisfies Review);
}

export async function fetchReviewFeed(): Promise<Review[]> {
  const q = query(reviewsCollection(), orderBy('createdAt', 'desc'), limit(50));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) => d.data());
}

export async function fetchReviewsForConcert(concertID: string): Promise<Review[]> {
  const q = query(reviewsCollection(), where('concertID', '==', concertID), orderBy('createdAt', 'desc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) => d.data());
}
