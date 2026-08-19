//
//  ConcertRepository.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import Foundation
import Combine
import FirebaseFirestore

/// Repository for managing Concert data in Firestore
final class ConcertRepository: ObservableObject {
    private let firestore = Firestore.firestore()
    private let concertsCollection = "concerts"
    
    // MARK: - Create
    
    /// Create a new concert in Firestore
    @MainActor
    func createConcert(_ concert: Concert) async throws {
        let docRef = firestore.collection(concertsCollection).document(concert.id)
        try await docRef.setData(concert.toFirestore())
    }
    
    // MARK: - Read
    
    /// Fetch all upcoming concerts
    @MainActor
    func fetchUpcomingConcerts() async throws -> [Concert] {
        let now = Date()
        let query = firestore.collection(concertsCollection)
            .whereField("date", isGreaterThanOrEqualTo: now)
            .order(by: "date", descending: false)
            .limit(to: 50)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Concert.fromFirestore(doc.data(), id: doc.documentID)
        }
    }
    
    /// Fetch concerts by venue
    @MainActor
    func fetchConcerts(byVenueID venueID: String) async throws -> [Concert] {
        let query = firestore.collection(concertsCollection)
            .whereField("venueID", isEqualTo: venueID)
            .order(by: "date", descending: false)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Concert.fromFirestore(doc.data(), id: doc.documentID)
        }
    }
    
    /// Search concerts by artist name
    @MainActor
    func searchConcerts(byArtist artist: String) async throws -> [Concert] {
        // Note: Firestore doesn't have great text search
        // For production, consider Algolia or fetch all and filter client-side
        let query = firestore.collection(concertsCollection)
            .order(by: "date", descending: false)
            .limit(to: 100)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            Concert.fromFirestore(doc.data(), id: doc.documentID)
        }.filter { concert in
            concert.artistName.localizedCaseInsensitiveContains(artist)
        }
    }
    
    /// Fetch a single concert by ID
    @MainActor
    func fetchConcert(id: String) async throws -> Concert {
        let docRef = firestore.collection(concertsCollection).document(id)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data(),
              let concert = Concert.fromFirestore(data, id: id) else {
            throw FirebaseError.documentNotFound
        }
        
        return concert
    }
    
    // MARK: - Update
    
    /// Update concert
    @MainActor
    func updateConcert(_ concert: Concert) async throws {
        let docRef = firestore.collection(concertsCollection).document(concert.id)
        try await docRef.setData(concert.toFirestore(), merge: true)
    }
    
    // MARK: - Delete
    
    /// Delete a concert
    @MainActor
    func deleteConcert(id: String) async throws {
        let docRef = firestore.collection(concertsCollection).document(id)
        try await docRef.delete()
    }
    
    // MARK: - Real-time Listening
    
    /// Listen to upcoming concerts
    @MainActor
    func listenToUpcomingConcerts(completion: @escaping ([Concert]) -> Void) -> ListenerRegistration {
        let now = Date()
        let query = firestore.collection(concertsCollection)
            .whereField("date", isGreaterThanOrEqualTo: now)
            .order(by: "date", descending: false)
            .limit(to: 50)
        
        return query.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                completion([])
                return
            }
            
            let concerts = snapshot.documents.compactMap { doc in
                Concert.fromFirestore(doc.data(), id: doc.documentID)
            }
            
            completion(concerts)
        }
    }
}
