//
//  AuthenticationViewModel.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth

/// ViewModel for handling authentication logic
@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var selectedSchool: School?
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var needsEmailVerification = false
    
    private let firebaseManager = FirebaseManager.shared
    private let userRepository = UserRepository()
    
    // MARK: - Validation
    
    var isEmailValid: Bool {
        email.contains("@") && firebaseManager.validateCollegeEmail(email)
    }
    
    var isPasswordValid: Bool {
        password.count >= 6
    }
    
    var isFormValid: Bool {
        isEmailValid && isPasswordValid && !displayName.isEmpty && selectedSchool != nil
    }
    
    // MARK: - Authentication Actions
    
    /// Sign up a new user
    func signUp() async {
        guard isFormValid else {
            errorMessage = "Please fill out all fields correctly."
            showError = true
            return
        }
        
        guard let school = selectedSchool else {
            errorMessage = "Please select your school."
            showError = true
            return
        }
        
        // Validate email domain matches school
        let emailDomain = extractDomain(from: email)
        guard emailDomain == school.emailDomain else {
            errorMessage = "Your email must match your school's domain (\(school.emailDomain))"
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            // Create Firebase auth user
            let firebaseUser = try await firebaseManager.signUp(email: email, password: password)
            
            // Create user profile in Firestore
            let user = User(
                id: firebaseUser.uid,
                email: email,
                displayName: displayName,
                schoolID: school.id,
                isEmailVerified: false,
                isProfilePublic: true
            )
            
            try await userRepository.createUser(user)
            
            // Show verification message
            needsEmailVerification = true
            errorMessage = "Account created! Please check your email to verify your account."
            showError = true
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    /// Sign in existing user
    func signIn() async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            let firebaseUser = try await firebaseManager.signIn(email: email, password: password)
            
            // Check if email is verified
            if !firebaseUser.isEmailVerified {
                needsEmailVerification = true
                errorMessage = "Please verify your email before signing in."
                showError = true
                try? firebaseManager.signOut()
                return
            }
            
            // Fetch user profile
            _ = try await userRepository.fetchUser(id: firebaseUser.uid)
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    /// Sign out current user
    func signOut() {
        do {
            try firebaseManager.signOut()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    /// Resend verification email
    func resendVerificationEmail() async {
        isLoading = true
        
        do {
            try await firebaseManager.resendVerificationEmail()
            errorMessage = "Verification email sent! Please check your inbox."
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    /// Reset password
    func resetPassword() async {
        guard isEmailValid else {
            errorMessage = "Please enter a valid email address."
            showError = true
            return
        }
        
        isLoading = true
        
        do {
            try await firebaseManager.resetPassword(email: email)
            errorMessage = "Password reset email sent!"
            showError = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Helper Methods
    
    private func extractDomain(from email: String) -> String {
        let components = email.lowercased().split(separator: "@")
        return components.count > 1 ? String(components[1]) : ""
    }
    
    /// Clear all form fields
    func clearForm() {
        email = ""
        password = ""
        displayName = ""
        selectedSchool = nil
        errorMessage = ""
        needsEmailVerification = false
    }
}
