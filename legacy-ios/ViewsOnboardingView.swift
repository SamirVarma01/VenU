//
//  OnboardingView.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Content
                Group {
                    switch viewModel.currentStep {
                    case .schoolSelection:
                        SchoolSelectionView(viewModel: viewModel)
                    case .emailAndPassword:
                        EmailPasswordView(viewModel: viewModel)
                    case .verification:
                        VerificationView(viewModel: viewModel)
                    }
                }
            }
            .alert("Notice", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - Step 1: School Selection

struct SchoolSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.gradient)
                
                Text("Select Your College")
                    .font(.largeTitle.bold())
                
                Text("Choose your school to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search schools...", text: $viewModel.searchText)
#if os(iOS)
                    .textInputAutocapitalization(.never)
#endif
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
#if os(iOS)
            .background(Color(uiColor: .systemBackground))
#else
            .background(Color(nsColor: .controlBackgroundColor))
#endif
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            // Schools list
            if viewModel.isLoading && viewModel.schools.isEmpty {
                ProgressView("Loading schools...")
                    .frame(maxHeight: .infinity)
            } else if viewModel.filteredSchools.isEmpty {
                ContentUnavailableView {
                    Label("No Schools Found", systemImage: "building.columns")
                } description: {
                    Text("Try a different search term")
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredSchools, id: \.id) { school in
                            SchoolRowView(
                                school: school,
                                isSelected: viewModel.selectedSchool?.id == school.id
                            ) {
                                withAnimation {
                                    viewModel.selectedSchool = school
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Continue button
            Button {
                viewModel.goToEmailStep()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isSchoolSelectionValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!viewModel.isSchoolSelectionValid)
            .padding()
        }
    }
}

struct SchoolRowView: View {
    let school: School
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue.gradient : Color.gray.opacity(0.2).gradient)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "building.columns")
                        .foregroundColor(isSelected ? .white : .gray)
                        .font(.title3)
                }
                
                // School info
                VStack(alignment: .leading, spacing: 4) {
                    Text(school.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text("\(school.city), \(school.state)")
                            .font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding()
#if os(iOS)
            .background(Color(uiColor: .systemBackground))
#else
            .background(Color(nsColor: .controlBackgroundColor))
#endif
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Step 2: Email and Password

struct EmailPasswordView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.fill.badge.plus")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.gradient)
                    
                    Text("Create Your Account")
                        .font(.largeTitle.bold())
                    
                    if let school = viewModel.selectedSchool {
                        Text(school.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 40)
                
                // Form fields
                VStack(spacing: 16) {
                    // Display Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("Your name", text: $viewModel.displayName)
#if os(iOS)
                            .textInputAutocapitalization(.words)
#endif
                            .textContentType(.name)
                            .padding()
#if os(iOS)
                            .background(Color(uiColor: .systemBackground))
#else
                            .background(Color(nsColor: .controlBackgroundColor))
#endif
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Email
                    VStack(alignment: .leading, spacing: 8) {
                        Text("College Email")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        TextField("you@\(viewModel.emailDomainHint)", text: $viewModel.email)
                            .textContentType(.emailAddress)
#if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
#endif
                            .padding()
#if os(iOS)
                            .background(Color(uiColor: .systemBackground))
#else
                            .background(Color(nsColor: .controlBackgroundColor))
#endif
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !viewModel.email.isEmpty {
                            let domain = viewModel.extractDomain(from: viewModel.email)
                            if domain != viewModel.emailDomainHint {
                                Label("Must use \(viewModel.emailDomainHint) email", systemImage: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                    
                    // Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        SecureField("At least 8 characters", text: $viewModel.password)
                            .textContentType(.newPassword)
                            .padding()
#if os(iOS)
                            .background(Color(uiColor: .systemBackground))
#else
                            .background(Color(nsColor: .controlBackgroundColor))
#endif
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !viewModel.password.isEmpty && viewModel.password.count < 8 {
                            Label("Password must be at least 8 characters", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    // Confirm Password
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        
                        SecureField("Re-enter password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .padding()
#if os(iOS)
                            .background(Color(uiColor: .systemBackground))
#else
                            .background(Color(nsColor: .controlBackgroundColor))
#endif
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !viewModel.confirmPassword.isEmpty && viewModel.password != viewModel.confirmPassword {
                            Label("Passwords don't match", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        Task {
                            await viewModel.goToVerificationStep()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isEmailStepValid ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .disabled(!viewModel.isEmailStepValid || viewModel.isLoading)
                    
                    Button {
                        viewModel.goBack()
                    } label: {
                        Text("Back")
                            .font(.subheadline)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Step 3: Email Verification

struct VerificationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isCodeFocused: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue.gradient)
                }
                
                Text("Check Your Email")
                    .font(.largeTitle.bold())
                
                Text("We sent a verification link to")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(viewModel.email)
                    .font(.subheadline.bold())
                    .foregroundStyle(.blue)
            }
            
            // Instructions
            VStack(spacing: 16) {
                InstructionRow(number: "1", text: "Check your email inbox")
                InstructionRow(number: "2", text: "Click the verification link")
                InstructionRow(number: "3", text: "Return here and tap 'I've Verified'")
            }
            .padding()
#if os(iOS)
            .background(Color(uiColor: .systemBackground))
#else
            .background(Color(nsColor: .controlBackgroundColor))
#endif
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                Button {
                    Task {
                        await viewModel.checkVerificationStatus()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("I've Verified My Email")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(viewModel.isLoading)
                
                Button {
                    Task {
                        await viewModel.resendVerificationEmail()
                    }
                } label: {
                    if viewModel.canResendCode {
                        Text("Resend Email")
                            .font(.subheadline)
                    } else {
                        Text("Resend in \(viewModel.resendCountdown)s")
                            .font(.subheadline)
                    }
                }
                .disabled(!viewModel.canResendCode || viewModel.isLoading)
                
                Button {
                    viewModel.goBack()
                } label: {
                    Text("Change Email")
                        .font(.subheadline)
                }
            }
            .padding()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 32, height: 32)
                
                Text(number)
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}
