// Ports legacy-ios/RepositoriesConcertRepository.swift.
//
// fetchUpcomingConcerts is a direct port. fetchConcertsNearSchool is NEW:
// the Swift prototype never implemented a geo query, it only had
// fetch-all / by-venue / by-artist. Venue already stores lat/lng and School
// stores lat/lng, so the data supports this — the query itself is the
// still-unbuilt part of the "concerts near your college" feature.

import { getDocs, limit, orderBy, query, where } from 'firebase/firestore';
import { concertsCollection } from '../../firebase/collections';
import type { Concert, School } from '../../types/models';

export async function fetchUpcomingConcerts(): Promise<Concert[]> {
  const now = Date.now();
  const q = query(
    concertsCollection(),
    where('date', '>=', now),
    orderBy('date', 'asc'),
    limit(50)
  );
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) => d.data());
}

export async function fetchConcertsByVenue(venueID: string): Promise<Concert[]> {
  const q = query(concertsCollection(), where('venueID', '==', venueID), orderBy('date', 'asc'));
  const snapshot = await getDocs(q);
  return snapshot.docs.map((d) => d.data());
}

/**
 * TODO(feature: concert discovery near college): not implemented.
 *
 * Firestore has no native geo-radius query. Options to build this out:
 *  - Store a geohash on each Venue and query geohash ranges (e.g. via a
 *    library like `geofire-common`), then filter precisely by distance
 *    client-side.
 *  - Or precompute/cache a school -> nearby venue IDs mapping (e.g. via a
 *    Cloud Function) and query concerts `where venueID in [...]`.
 * For now this just falls back to fetchUpcomingConcerts so callers have
 * something to render.
 */
export async function fetchConcertsNearSchool(school: School): Promise<Concert[]> {
  void school;
  return fetchUpcomingConcerts();
}
