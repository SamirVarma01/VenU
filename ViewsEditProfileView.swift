//
//  EditProfileView.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // Display Name Section
                Section {
                    TextField("Display Name", text: $viewModel.editedDisplayName)
#if os(iOS)
                        .textInputAutocapitalization(.words)
#endif
                } header: {
                    Text("Display Name")
                } footer: {
                    Text("This is how other students will see you")
                }
                
                // Bio Section
                Section {
                    TextEditor(text: $viewModel.editedBio)
                        .frame(minHeight: 100)
                } header: {
                    Text("Bio")
                } footer: {
                    Text("Tell others about your music taste and concert experience")
                }
                
                // Privacy Section
                Section {
                    Toggle("Public Profile", isOn: $viewModel.editedIsProfilePublic)
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("When public, other students can see your profile and concerts you're attending")
                }
                
                // Email Verification
                if !viewModel.isEmailVerified {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Email not verified", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            
                            Button("Resend Verification Email") {
                                Task {
                                    await viewModel.resendVerificationEmail()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateProfile()
                            if viewModel.successMessage.contains("updated") {
                                dismiss()
                            }
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.editedDisplayName.isEmpty)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview {
    EditProfileView(viewModel: UserProfileViewModel())
}
