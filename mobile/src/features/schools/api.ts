// Ports legacy-ios/RepositoriesSchoolRepository.swift

import { getDocs, query, orderBy } from 'firebase/firestore';
import { schoolsCollection } from '../../firebase/collections';
import type { School } from '../../types/models';

export async function fetchAllSchools(): Promise<School[]> {
  const snapshot = await getDocs(query(schoolsCollection(), orderBy('name')));
  return snapshot.docs.map((d) => d.data());
}
