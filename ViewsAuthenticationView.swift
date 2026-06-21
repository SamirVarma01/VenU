//
//  AuthenticationView.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Logo/Header
                VStack(spacing: 8) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("VenU")
                        .font(.largeTitle.bold())
                    
                    Text("Find concert buddies at your college")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 40)
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("College Email")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("you@university.edu", text: $email)
                        .textContentType(.emailAddress)
#if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
#endif
                        .padding()
#if os(iOS)
                        .background(Color(uiColor: .systemGray6))
#else
                        .background(Color(nsColor: .controlBackgroundColor))
#endif
                        .cornerRadius(10)
                }
                
                // Password Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
#if os(iOS)
                        .background(Color(uiColor: .systemGray6))
#else
                        .background(Color(nsColor: .controlBackgroundColor))
#endif
                        .cornerRadius(10)
                }
                
                // Sign In/Up Button
                Button {
                    handleAuthentication()
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!isFormValid || isLoading)
                
                // Toggle Sign In/Up
                Button {
                    isSignUp.toggle()
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                }
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(24)
            .navigationTitle(isSignUp ? "Create Account" : "Welcome Back")
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        !password.isEmpty && 
        email.contains("@") &&
        password.count >= 6
    }
    
    private func handleAuthentication() {
        guard isFormValid else { return }
        
        // Validate college email
        guard firebaseManager.validateCollegeEmail(email) else {
            errorMessage = "Please use a valid college email address (.edu)"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                if isSignUp {
                    _ = try await firebaseManager.signUp(email: email, password: password)
                    // Show verification message
                    errorMessage = "Account created! Please check your email to verify your account."
                    showError = true
                } else {
                    _ = try await firebaseManager.signIn(email: email, password: password)
                }
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isLoading = false
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(FirebaseManager.shared)
}
