//
//  ContentView.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        // Show onboarding view if not logged in
        if !firebaseManager.isAuthenticated {
            OnboardingView()
        } else {
            mainContentView
        }
    }
    
    private var mainContentView: some View {
#if os(iOS)
        TabView {
            ConcertBrowserView()
                .tabItem {
                    Label("Concerts", systemImage: "music.note.list")
                }
            
            ProfilePlaceholderView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
#else
        NavigationSplitView {
            List {
                NavigationLink {
                    ConcertBrowserView()
                } label: {
                    Label("Concerts", systemImage: "music.note.list")
                }
                
                NavigationLink {
                    ProfilePlaceholderView()
                } label: {
                    Label("Profile", systemImage: "person.circle")
                }
            }
            .navigationTitle("VenU")
        } detail: {
            Text("Select a section")
        }
#endif
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

// MARK: - Placeholder Views

struct ProfilePlaceholderView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @State private var isSeeding = false
    @State private var seedMessage = ""
    @State private var showSeedMessage = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(.blue)
                
                if let user = firebaseManager.currentUser {
                    Text(user.email ?? "No email")
                        .font(.title3)
                }
                
                Text("Profile page coming soon!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Divider()
                    .padding(.vertical)
                
                // Developer Tools
                VStack(spacing: 12) {
                    Text("Developer Tools")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    
                    Button {
                        Task {
                            await seedSampleData()
                        }
                    } label: {
                        if isSeeding {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Label("Seed Sample Concerts", systemImage: "wand.and.stars")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSeeding)
                }
                
                Spacer()
                
                Button("Sign Out") {
                    try? firebaseManager.signOut()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Profile")
            .alert("Seeding Data", isPresented: $showSeedMessage) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(seedMessage)
            }
        }
    }
    
    private func seedSampleData() async {
        isSeeding = true
        
        do {
            try await SampleDataSeeder.seedSampleConcerts()
            seedMessage = "Successfully added 8 sample concerts!"
            showSeedMessage = true
        } catch {
            seedMessage = "Error seeding data: \(error.localizedDescription)"
            showSeedMessage = true
        }
        
        isSeeding = false
    }
}

fileprivate struct NavigationViewWrapper<Content: View>: View {
    let content: () -> Content

    var body: some View {
#if os(macOS)
        NavigationSplitView {
            content()
        } detail: {
            Text("Select an item")
        }
#else
        content()
#endif
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
