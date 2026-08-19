// NEW — legacy-ios only had the Message SwiftData model, no repository.
// Stub CRUD over the `messages` collection to give the feature a home;
// not wired into any screen yet.

import { addDoc, getDocs, orderBy, query, where } from 'firebase/firestore';
import { messagesCollection } from '../../firebase/collections';
import type { Message } from '../../types/models';

export async function sendMessage(
  conversationID: string,
  senderID: string,
  recipientID: string,
  content: string
): Promise<void> {
  await addDoc(messagesCollection(), {
    id: '',
    conversationID,
    senderID,
    recipientID,
    messageType: 'text',
    content,
    isRead: false,
    createdAt: Date.now(),
  } satisfies Message);
}

export async function fetchConversation(conversationID: string): Promise<Message[]> {
  const q = query(
    messagesCollection(),
    where('conversationID', '==', conversationID),
    orderBy('createdAt', 'asc')
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) => d.data());
}
