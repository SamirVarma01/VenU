// Ports legacy-ios/ServicesFirebaseManager.swift's auth methods to the
// Firebase JS SDK, plus the college-email validation from the same file.

import {
  createUserWithEmailAndPassword,
  sendEmailVerification,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signOut as firebaseSignOut,
  type User as FirebaseUser,
} from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';
import { auth } from '../../firebase/config';
import { usersCollection } from '../../firebase/collections';
import type { User } from '../../types/models';

const COLLEGE_EMAIL_SUFFIXES = ['.edu', '.ac.uk', '.ac.in'];

export function validateCollegeEmail(email: string): boolean {
  const lower = email.toLowerCase();
  return COLLEGE_EMAIL_SUFFIXES.some((suffix) => lower.endsWith(suffix));
}

export function extractDomain(email: string): string {
  const parts = email.toLowerCase().split('@');
  return parts.length > 1 ? parts[1] : '';
}

export async function signUp(email: string, password: string): Promise<FirebaseUser> {
  const result = await createUserWithEmailAndPassword(auth, email, password);
  await sendEmailVerification(result.user);
  return result.user;
}

export async function createUserProfile(user: User): Promise<void> {
  await setDoc(doc(usersCollection(), user.id), user);
}

export async function signIn(email: string, password: string): Promise<FirebaseUser> {
  const result = await signInWithEmailAndPassword(auth, email, password);
  return result.user;
}

export async function signOut(): Promise<void> {
  await firebaseSignOut(auth);
}

export async function resetPassword(email: string): Promise<void> {
  await sendPasswordResetEmail(auth, email);
}

export async function resendVerificationEmail(): Promise<void> {
  if (!auth.currentUser) {
    throw new Error('You must be signed in to perform this action.');
  }
  await sendEmailVerification(auth.currentUser);
}

export async function reloadCurrentUser(): Promise<FirebaseUser | null> {
  if (!auth.currentUser) return null;
  await auth.currentUser.reload();
  return auth.currentUser;
}
