//
//  UserProfileView.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import SwiftUI

struct UserProfileView: View {
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showEditProfile = false
    @State private var showSeeding = false
    @State private var isSeeding = false
    @State private var seedMessage = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.user == nil {
                    ProgressView("Loading profile...")
                } else if let user = viewModel.user {
                    profileContent(user: user)
                } else {
                    errorStateView
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showEditProfile = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .disabled(viewModel.user == nil)
                }
            }
            .task {
                await viewModel.loadCurrentUserProfile()
            }
            .refreshable {
                await viewModel.loadCurrentUserProfile()
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
    
    // MARK: - Profile Content
    
    private func profileContent(user: User) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 16) {
                    // Profile Image Placeholder
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                        
                        Text(user.displayName.prefix(1).uppercased())
                            .font(.system(size: 50, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Name and Email
                    VStack(spacing: 4) {
                        Text(user.displayName)
                            .font(.title.bold())
                        
                        HStack(spacing: 8) {
                            Text(viewModel.userEmail)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if viewModel.isEmailVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundStyle(.blue)
                            } else {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }
                .padding(.top, 20)
                
                // Stats Section
                HStack(spacing: 32) {
                    StatView(title: "Concerts", value: "0")
                    StatView(title: "Friends", value: "0")
                    StatView(title: "Attended", value: "0")
                }
                .padding()
#if os(iOS)
                .background(Color(uiColor: .secondarySystemBackground))
#else
                .background(Color(nsColor: .controlBackgroundColor))
#endif
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                
                // Info Sections
                VStack(spacing: 16) {
                    // Bio
                    if let bio = user.bio, !bio.isEmpty {
                        InfoCard(title: "Bio", icon: "text.quote") {
                            Text(bio)
                                .font(.body)
                        }
                    }
                    
                    // Account Info
                    InfoCard(title: "Account Info", icon: "person.text.rectangle") {
                        VStack(spacing: 12) {
                            InfoRow(label: "Member Since", value: viewModel.memberSince)
                            Divider()
                            InfoRow(
                                label: "Profile Visibility",
                                value: user.isProfilePublic ? "Public" : "Private"
                            )
                            Divider()
                            InfoRow(
                                label: "Email Status",
                                value: viewModel.isEmailVerified ? "Verified" : "Not Verified"
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                // Developer Tools (can be removed later)
                #if DEBUG
                InfoCard(title: "Developer Tools", icon: "hammer") {
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await seedSchools()
                            }
                        } label: {
                            if isSeeding {
                                ProgressView()
                            } else {
                                Label("Seed Sample Schools", systemImage: "building.columns")
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            Task {
                                await seedSampleData()
                            }
                        } label: {
                            if isSeeding {
                                ProgressView()
                            } else {
                                Label("Seed Sample Concerts", systemImage: "wand.and.stars")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isSeeding)
                    }
                }
                .padding(.horizontal)
                #endif
                
                // Sign Out Button
                Button(role: .destructive) {
                    viewModel.signOut()
                } label: {
                    Label("Sign Out", systemImage: "arrow.right.square")
                        .frame(maxWidth: .infinity)
                        .padding()
#if os(iOS)
                        .background(Color(uiColor: .secondarySystemBackground))
#else
                        .background(Color(nsColor: .controlBackgroundColor))
#endif
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Error State
    
    private var errorStateView: some View {
        ContentUnavailableView {
            Label("Profile Unavailable", systemImage: "person.crop.circle.badge.exclamationmark")
        } description: {
            Text("Unable to load your profile. Please try again.")
        } actions: {
            Button("Retry") {
                Task {
                    await viewModel.loadCurrentUserProfile()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Helper Methods
    
    private func seedSchools() async {
        isSeeding = true
        
        do {
            try await SampleDataSeeder.seedSampleSchools()
            viewModel.successMessage = "Successfully added 11 sample schools!"
            viewModel.showSuccess = true
        } catch {
            viewModel.errorMessage = "Error seeding schools: \(error.localizedDescription)"
            viewModel.showError = true
        }
        
        isSeeding = false
    }
    
    private func seedSampleData() async {
        isSeeding = true
        
        do {
            try await SampleDataSeeder.seedSampleConcerts()
            seedMessage = "Successfully added 8 sample concerts!"
            viewModel.successMessage = seedMessage
            viewModel.showSuccess = true
        } catch {
            viewModel.errorMessage = "Error seeding data: \(error.localizedDescription)"
            viewModel.showError = true
        }
        
        isSeeding = false
    }
}

// MARK: - Supporting Views

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
#if os(iOS)
        .background(Color(uiColor: .secondarySystemBackground))
#else
        .background(Color(nsColor: .controlBackgroundColor))
#endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    UserProfileView()
        .environmentObject(FirebaseManager.shared)
}
