//
//  UserRepository.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import Combine
import FirebaseFirestore
import SwiftData

/// Repository for managing User data in Firestore and SwiftData
final class UserRepository: ObservableObject {
    private let firestore = Firestore.firestore()
    private let usersCollection = "users"
    
    // MARK: - Create
    
    /// Create a new user in Firestore
    func createUser(_ user: User) async throws {
        let docRef = firestore.collection(usersCollection).document(user.id)
        try await docRef.setData(user.toFirestore())
    }
    
    // MARK: - Read
    
    /// Fetch a user by ID from Firestore
    func fetchUser(id: String) async throws -> User {
        let docRef = firestore.collection(usersCollection).document(id)
        let snapshot = try await docRef.getDocument()
        
        guard let data = snapshot.data(),
              let user = User.fromFirestore(data, id: id) else {
            throw FirebaseError.userNotFound
        }
        
        return user
    }
    
    /// Fetch users by school ID
    func fetchUsers(bySchoolID schoolID: String) async throws -> [User] {
        let query = firestore.collection(usersCollection)
            .whereField("schoolID", isEqualTo: schoolID)
            .whereField("isProfilePublic", isEqualTo: true)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            User.fromFirestore(doc.data(), id: doc.documentID)
        }
    }
    
    /// Search users by display name
    func searchUsers(byName name: String, schoolID: String) async throws -> [User] {
        // Note: Firestore doesn't have great text search capabilities
        // For production, consider using Algolia or similar
        let query = firestore.collection(usersCollection)
            .whereField("schoolID", isEqualTo: schoolID)
            .whereField("isProfilePublic", isEqualTo: true)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            User.fromFirestore(doc.data(), id: doc.documentID)
        }.filter { user in
            user.displayName.localizedCaseInsensitiveContains(name)
        }
    }
    
    // MARK: - Update
    
    /// Update user profile
    func updateUser(_ user: User) async throws {
        let docRef = firestore.collection(usersCollection).document(user.id)
        try await docRef.setData(user.toFirestore(), merge: true)
    }
    
    /// Update profile visibility
    func updateProfileVisibility(userID: String, isPublic: Bool) async throws {
        let docRef = firestore.collection(usersCollection).document(userID)
        try await docRef.updateData(["isProfilePublic": isPublic])
    }
    
    // MARK: - Delete
    
    /// Delete a user
    func deleteUser(id: String) async throws {
        let docRef = firestore.collection(usersCollection).document(id)
        try await docRef.delete()
    }
    
    // MARK: - Real-time Listening
    
    /// Listen to user updates
    func listenToUser(id: String, completion: @escaping (User?) -> Void) -> ListenerRegistration {
        let docRef = firestore.collection(usersCollection).document(id)
        
        return docRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot,
                  let data = snapshot.data(),
                  let user = User.fromFirestore(data, id: id) else {
                completion(nil)
                return
            }
            
            completion(user)
        }
    }
}
