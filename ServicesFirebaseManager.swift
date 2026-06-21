//
//  FirebaseManager.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

/// Singleton manager for Firebase services
final class FirebaseManager: ObservableObject {
    static let shared = FirebaseManager()
    
    let auth: Auth
    let firestore: Firestore
    
    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated = false
    
    private init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        // Set up auth state listener
        self.currentUser = auth.currentUser
        self.isAuthenticated = auth.currentUser != nil
        
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up with email and password
    @MainActor
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await result.user.sendEmailVerification()
        return result.user
    }
    
    /// Sign in with email and password
    @MainActor
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }
    
    /// Sign out
    @MainActor
    func signOut() throws {
        try auth.signOut()
    }
    
    /// Send password reset email
    @MainActor
    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    /// Check if email is verified
    var isEmailVerified: Bool {
        currentUser?.isEmailVerified ?? false
    }
    
    /// Resend verification email
    @MainActor
    func resendVerificationEmail() async throws {
        guard let user = currentUser else {
            throw FirebaseError.notAuthenticated
        }
        try await user.sendEmailVerification()
    }
    
    /// Reload current user (to check email verification status)
    @MainActor
    func reloadUser() async throws {
        try await currentUser?.reload()
        self.currentUser = auth.currentUser
    }
    
    /// Validate if email belongs to a college domain
    func validateCollegeEmail(_ email: String) -> Bool {
        let eduDomains = [".edu", ".ac.uk", ".ac.in"] // Add more as needed
        return eduDomains.contains { email.lowercased().hasSuffix($0) }
    }
}

// MARK: - Firebase Errors
enum FirebaseError: LocalizedError {
    case notAuthenticated
    case emailNotVerified
    case invalidCollegeEmail
    case userNotFound
    case documentNotFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .emailNotVerified:
            return "Please verify your email address before continuing."
        case .invalidCollegeEmail:
            return "Please use a valid college email address (.edu)."
        case .userNotFound:
            return "User not found."
        case .documentNotFound:
            return "Document not found in Firestore."
        }
    }
}
