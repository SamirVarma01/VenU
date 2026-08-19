//
//  SchoolRepository.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import Foundation
import Combine
import FirebaseFirestore

/// Repository for managing School data in Firestore
final class SchoolRepository: ObservableObject {
    private let firestore = Firestore.firestore()
    private let schoolsCollection = "schools"
    
    // MARK: - Create
    
    /// Create a new school in Firestore
    @MainActor
    func createSchool(_ school: School) async throws {
        let docRef = firestore.collection(schoolsCollection).document(school.id)
        try await docRef.setData(school.toFirestore())
    }
    
    // MARK: - Read
    
    /// Fetch all schools
    @MainActor
    func fetchAllSchools() async throws -> [School] {
        let query = firestore.collection(schoolsCollection)
            .order(by: "name", descending: false)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            School.fromFirestore(doc.data(), id: doc.documentID)
        }
    }
    
    /// Fetch a school by ID
    @MainActor
    func fetchSchool(id: String) async throws -> School {
        let docRef = firestore.collection(schoolsCollection).document(id)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data(),
              let school = School.fromFirestore(data, id: id) else {
            throw FirebaseError.documentNotFound
        }
        
        return school
    }
    
    /// Fetch school by email domain
    @MainActor
    func fetchSchool(byEmailDomain domain: String) async throws -> School? {
        let query = firestore.collection(schoolsCollection)
            .whereField("emailDomain", isEqualTo: domain)
            .limit(to: 1)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            School.fromFirestore(doc.data(), id: doc.documentID)
        }.first
    }
    
    // MARK: - Update
    
    /// Update school
    @MainActor
    func updateSchool(_ school: School) async throws {
        let docRef = firestore.collection(schoolsCollection).document(school.id)
        try await docRef.setData(school.toFirestore(), merge: true)
    }
    
    // MARK: - Delete
    
    /// Delete a school
    @MainActor
    func deleteSchool(id: String) async throws {
        let docRef = firestore.collection(schoolsCollection).document(id)
        try await docRef.delete()
    }
}
