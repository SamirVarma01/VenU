import { collection, type CollectionReference, type DocumentData } from 'firebase/firestore';
import { db } from './config';

function typedCollection<T extends DocumentData>(path: string): CollectionReference<T> {
  return collection(db, path) as CollectionReference<T>;
}

import type { Concert, Friendship, Message, Review, School, User, Venue } from '../types/models';

export const usersCollection = () => typedCollection<User>('users');
export const schoolsCollection = () => typedCollection<School>('schools');
export const concertsCollection = () => typedCollection<Concert>('concerts');
export const venuesCollection = () => typedCollection<Venue>('venues');
export const friendshipsCollection = () => typedCollection<Friendship>('friendships');
export const messagesCollection = () => typedCollection<Message>('messages');
export const reviewsCollection = () => typedCollection<Review>('reviews');
