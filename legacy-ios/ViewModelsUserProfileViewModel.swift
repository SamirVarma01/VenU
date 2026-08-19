//
//  UserProfileViewModel.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth

/// ViewModel for user profile management
@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var successMessage = ""
    @Published var showSuccess = false
    
    // Edit state
    @Published var editedDisplayName = ""
    @Published var editedBio = ""
    @Published var editedIsProfilePublic = true
    
    private let firebaseManager = FirebaseManager.shared
    private let userRepository = UserRepository()
    
    // MARK: - Load Profile
    
    func loadCurrentUserProfile() async {
        guard let firebaseUser = firebaseManager.currentUser else {
            errorMessage = "No authenticated user found"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            user = try await userRepository.fetchUser(id: firebaseUser.uid)
            
            // Populate edit fields
            if let user = user {
                editedDisplayName = user.displayName
                editedBio = user.bio ?? ""
                editedIsProfilePublic = user.isProfilePublic
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Update Profile
    
    func updateProfile() async {
        guard var currentUser = user else {
            errorMessage = "No user data to update"
            showError = true
            return
        }
        
        guard !editedDisplayName.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Display name cannot be empty"
            showError = true
            return
        }
        
        isLoading = true
        
        // Update local user object
        currentUser.displayName = editedDisplayName.trimmingCharacters(in: .whitespaces)
        currentUser.bio = editedBio.isEmpty ? nil : editedBio.trimmingCharacters(in: .whitespaces)
        currentUser.isProfilePublic = editedIsProfilePublic
        currentUser.updatedAt = Date()
        
        do {
            try await userRepository.updateUser(currentUser)
            user = currentUser
            successMessage = "Profile updated successfully!"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Profile Visibility
    
    func toggleProfileVisibility() async {
        guard let firebaseUser = firebaseManager.currentUser else { return }
        
        isLoading = true
        let newVisibility = !editedIsProfilePublic
        
        do {
            try await userRepository.updateProfileVisibility(
                userID: firebaseUser.uid,
                isPublic: newVisibility
            )
            editedIsProfilePublic = newVisibility
            user?.isProfilePublic = newVisibility
            successMessage = "Privacy settings updated"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Computed Properties
    
    var isEmailVerified: Bool {
        firebaseManager.currentUser?.isEmailVerified ?? false
    }
    
    var userEmail: String {
        firebaseManager.currentUser?.email ?? "No email"
    }
    
    var memberSince: String {
        guard let user = user else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: user.createdAt)
    }
    
    // MARK: - Actions
    
    func resendVerificationEmail() async {
        isLoading = true
        
        do {
            try await firebaseManager.resendVerificationEmail()
            successMessage = "Verification email sent!"
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try firebaseManager.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
