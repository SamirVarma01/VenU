// Mirrors the Firestore document shapes from the original SwiftData models
// in legacy-ios/ (Models*.swift). Field names match 1:1 so existing Firestore
// data / security rules keep working.

export interface School {
  id: string;
  name: string;
  emailDomain: string; // e.g. "stanford.edu"
  latitude: number;
  longitude: number;
  city: string;
  state: string;
  country: string;
}

export interface User {
  id: string;
  email: string;
  displayName: string;
  schoolID: string;
  profileImageURL?: string;
  isEmailVerified: boolean;
  isProfilePublic: boolean;
  createdAt: number; // ms since epoch
  updatedAt: number;
  bio?: string;
}

export interface Venue {
  id: string;
  name: string;
  address: string;
  city: string;
  state: string;
  country: string;
  zipCode?: string;
  latitude: number;
  longitude: number;
  capacity?: number;
  imageURL?: string;
  source: string; // "ticketmaster", "manual", etc.
  externalID: string;
}

export interface Concert {
  id: string;
  name: string;
  artistName: string;
  venueID: string;
  venueName: string;
  date: number; // ms since epoch
  imageURL?: string;
  ticketURL?: string;
  minPrice?: number;
  maxPrice?: number;
  currency: string;
  genre?: string;
  source: string;
  externalID: string;
  lastUpdated: number;
}

export type FriendshipStatus = 'pending' | 'accepted' | 'blocked';

export interface Friendship {
  id: string;
  requesterID: string;
  recipientID: string;
  status: FriendshipStatus;
  createdAt: number;
  updatedAt: number;
}

export type MessageType = 'text' | 'image' | 'concertShare';

export interface Message {
  id: string;
  conversationID: string;
  senderID: string;
  recipientID: string;
  messageType: MessageType;
  content: string;
  imageURL?: string;
  concertID?: string;
  isRead: boolean;
  createdAt: number;
}

// New — did not exist in the Swift prototype. Backs the review/post feed
// microservice: a short review a student posts about a concert.
export interface Review {
  id: string;
  concertID: string;
  authorID: string;
  authorDisplayName: string;
  rating: number; // 1-5
  content: string;
  imageURL?: string;
  createdAt: number;
}
