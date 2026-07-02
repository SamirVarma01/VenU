//
//  OnboardingViewModel.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import Foundation
import Combine
import SwiftUI
import FirebaseAuth

/// ViewModel for multi-step onboarding
@MainActor
final class OnboardingViewModel: ObservableObject {
    // Step tracking
    @Published var currentStep: OnboardingStep = .schoolSelection
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showError = false
    
    // School selection
    @Published var schools: [School] = []
    @Published var selectedSchool: School?
    @Published var searchText = ""
    
    // Email and password
    @Published var email = ""
    @Published var displayName = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    // Verification code
    @Published var verificationCode = ""
    @Published var canResendCode = true
    @Published var resendCountdown = 0
    
    private let firebaseManager = FirebaseManager.shared
    private let schoolRepository = SchoolRepository()
    private let userRepository = UserRepository()
    private var resendTimer: Timer?
    
    // MARK: - Lifecycle
    
    init() {
        Task {
            await loadSchools()
        }
    }
    
    // MARK: - Load Schools
    
    func loadSchools() async {
        isLoading = true
        
        do {
            schools = try await schoolRepository.fetchAllSchools()
        } catch {
            errorMessage = "Failed to load schools: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Computed Properties
    
    var filteredSchools: [School] {
        if searchText.isEmpty {
            return schools
        } else {
            return schools.filter { school in
                school.name.localizedCaseInsensitiveContains(searchText) ||
                school.city.localizedCaseInsensitiveContains(searchText) ||
                school.state.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var isSchoolSelectionValid: Bool {
        selectedSchool != nil
    }
    
    var isEmailStepValid: Bool {
        guard let school = selectedSchool else { return false }
        let emailDomain = extractDomain(from: email)
        return !email.isEmpty &&
               !displayName.isEmpty &&
               emailDomain == school.emailDomain &&
               password.count >= 8 &&
               password == confirmPassword
    }
    
    var emailDomainHint: String {
        selectedSchool?.emailDomain ?? ""
    }
    
    var isVerificationCodeValid: Bool {
        verificationCode.count == 6 && verificationCode.allSatisfy { $0.isNumber }
    }
    
    // MARK: - Navigation
    
    func goToEmailStep() {
        guard isSchoolSelectionValid else {
            errorMessage = "Please select your school"
            showError = true
            return
        }
        currentStep = .emailAndPassword
    }
    
    func goToVerificationStep() async {
        guard isEmailStepValid else {
            errorMessage = "Please fill out all fields correctly"
            showError = true
            return
        }
        
        await createAccount()
    }
    
    func goBack() {
        switch currentStep {
        case .schoolSelection:
            break
        case .emailAndPassword:
            currentStep = .schoolSelection
        case .verification:
            currentStep = .emailAndPassword
        }
    }
    
    // MARK: - Account Creation
    
    private func createAccount() async {
        guard let school = selectedSchool else { return }
        
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
            
            // Move to verification step
            currentStep = .verification
            startResendTimer()
            
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Email Verification
    
    func checkVerificationStatus() async {
        isLoading = true
        
        do {
            try await firebaseManager.reloadUser()
            
            if firebaseManager.isEmailVerified {
                // Update user in Firestore
                if let firebaseUser = firebaseManager.currentUser {
                    var user = try await userRepository.fetchUser(id: firebaseUser.uid)
                    user.isEmailVerified = true
                    try await userRepository.updateUser(user)
                }
                
                // Success - user is now verified and logged in
                // The ContentView will automatically show main app
            } else {
                errorMessage = "Email not verified yet. Please check your inbox."
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    func resendVerificationEmail() async {
        guard canResendCode else { return }
        
        isLoading = true
        
        do {
            try await firebaseManager.resendVerificationEmail()
            errorMessage = "Verification email sent! Check your inbox."
            showError = true
            startResendTimer()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        
        isLoading = false
    }
    
    private func startResendTimer() {
        canResendCode = false
        resendCountdown = 60
        
        resendTimer?.invalidate()
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            Task { @MainActor in
                self.resendCountdown -= 1
                if self.resendCountdown <= 0 {
                    self.canResendCode = true
                    timer.invalidate()
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func extractDomain(from email: String) -> String {
        let components = email.lowercased().split(separator: "@")
        return components.count > 1 ? String(components[1]) : ""
    }
    
    deinit {
        resendTimer?.invalidate()
    }
}

// MARK: - Onboarding Steps

enum OnboardingStep {
    case schoolSelection
    case emailAndPassword
    case verification
}
