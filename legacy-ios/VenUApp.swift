//
//  VenUApp.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import SwiftUI
import SwiftData

@main
struct VenUApp: App {
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            // Keep old model for migration purposes
            Item.self,
            // New models
            User.self,
            School.self,
            Concert.self,
            Venue.self,
            ConcertAttendance.self,
            Friendship.self,
            Message.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(firebaseManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
