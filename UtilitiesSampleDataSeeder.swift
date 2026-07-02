//
//  SampleDataSeeder.swift
//  VenU
//
//  Created by Samir Varma on 6/21/26.
//

import Foundation

/// Helper to seed sample data for testing
struct SampleDataSeeder {
    static let concertRepository = ConcertRepository()
    static let schoolRepository = SchoolRepository()
    
    /// Seed sample schools
    @MainActor
    static func seedSampleSchools() async throws {
        let sampleSchools = [
            School(
                id: "stanford",
                name: "Stanford University",
                emailDomain: "stanford.edu",
                latitude: 37.4275,
                longitude: -122.1697,
                city: "Stanford",
                state: "CA"
            ),
            School(
                id: "berkeley",
                name: "UC Berkeley",
                emailDomain: "berkeley.edu",
                latitude: 37.8719,
                longitude: -122.2585,
                city: "Berkeley",
                state: "CA"
            ),
            School(
                id: "mit",
                name: "Massachusetts Institute of Technology",
                emailDomain: "mit.edu",
                latitude: 42.3601,
                longitude: -71.0942,
                city: "Cambridge",
                state: "MA"
            ),
            School(
                id: "harvard",
                name: "Harvard University",
                emailDomain: "harvard.edu",
                latitude: 42.3770,
                longitude: -71.1167,
                city: "Cambridge",
                state: "MA"
            ),
            School(
                id: "nyu",
                name: "New York University",
                emailDomain: "nyu.edu",
                latitude: 40.7291,
                longitude: -73.9965,
                city: "New York",
                state: "NY"
            ),
            School(
                id: "usc",
                name: "University of Southern California",
                emailDomain: "usc.edu",
                latitude: 34.0224,
                longitude: -118.2851,
                city: "Los Angeles",
                state: "CA"
            ),
            School(
                id: "columbia",
                name: "Columbia University",
                emailDomain: "columbia.edu",
                latitude: 40.8075,
                longitude: -73.9626,
                city: "New York",
                state: "NY"
            ),
            School(
                id: "yale",
                name: "Yale University",
                emailDomain: "yale.edu",
                latitude: 41.3163,
                longitude: -72.9223,
                city: "New Haven",
                state: "CT"
            ),
            School(
                id: "princeton",
                name: "Princeton University",
                emailDomain: "princeton.edu",
                latitude: 40.3430,
                longitude: -74.6514,
                city: "Princeton",
                state: "NJ"
            ),
            School(
                id: "ucla",
                name: "University of California, Los Angeles",
                emailDomain: "ucla.edu",
                latitude: 34.0689,
                longitude: -118.4452,
                city: "Los Angeles",
                state: "CA"
            ),
            School(
                id: "rutgers",
                name: "Rutgers University",
                emailDomain: "rutgers.edu",
                latitude: 40.5008,
                longitude: -74.4474,
                city: "New Brunswick",
                state: "NJ"
            )
        ]
        
        // Upload each school to Firestore
        for school in sampleSchools {
            try await schoolRepository.createSchool(school)
        }
        
        print("✅ Seeded \(sampleSchools.count) sample schools!")
    }
    
    /// Seed sample concerts
    @MainActor
    static func seedSampleConcerts() async throws {
        let sampleConcerts = [
            Concert(
                id: UUID().uuidString,
                name: "The Eras Tour",
                artistName: "Taylor Swift",
                venueID: "venue1",
                venueName: "Madison Square Garden",
                date: Date().addingTimeInterval(86400 * 7), // 1 week
                ticketURL: "https://www.ticketmaster.com",
                minPrice: 120.0,
                maxPrice: 250.0,
                genre: "Pop",
                source: "manual",
                externalID: "ts-eras-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "Big Steppers Tour",
                artistName: "Kendrick Lamar",
                venueID: "venue2",
                venueName: "The Forum",
                date: Date().addingTimeInterval(86400 * 14), // 2 weeks
                minPrice: 95.0,
                maxPrice: 180.0,
                genre: "Hip Hop",
                source: "manual",
                externalID: "kl-bigsteppers-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "Happier Than Ever Tour",
                artistName: "Billie Eilish",
                venueID: "venue3",
                venueName: "Crypto.com Arena",
                date: Date().addingTimeInterval(86400 * 21), // 3 weeks
                minPrice: 75.0,
                maxPrice: 150.0,
                genre: "Alternative",
                source: "manual",
                externalID: "be-happier-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "After Hours til Dawn",
                artistName: "The Weeknd",
                venueID: "venue4",
                venueName: "SoFi Stadium",
                date: Date().addingTimeInterval(86400 * 28), // 4 weeks
                minPrice: 100.0,
                maxPrice: 200.0,
                genre: "R&B",
                source: "manual",
                externalID: "tw-afterhours-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "The Car Tour",
                artistName: "Arctic Monkeys",
                venueID: "venue5",
                venueName: "Red Rocks Amphitheatre",
                date: Date().addingTimeInterval(86400 * 35), // 5 weeks
                minPrice: 65.0,
                maxPrice: 120.0,
                genre: "Indie Rock",
                source: "manual",
                externalID: "am-car-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "World's Hottest Tour",
                artistName: "Bad Bunny",
                venueID: "venue6",
                venueName: "MetLife Stadium",
                date: Date().addingTimeInterval(86400 * 42), // 6 weeks
                minPrice: 85.0,
                maxPrice: 175.0,
                genre: "Reggaeton",
                source: "manual",
                externalID: "bb-hottest-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "SOS Tour",
                artistName: "SZA",
                venueID: "venue7",
                venueName: "Barclays Center",
                date: Date().addingTimeInterval(86400 * 49), // 7 weeks
                minPrice: 80.0,
                maxPrice: 140.0,
                genre: "R&B",
                source: "manual",
                externalID: "sza-sos-1"
            ),
            Concert(
                id: UUID().uuidString,
                name: "Love On Tour",
                artistName: "Harry Styles",
                venueID: "venue8",
                venueName: "Wembley Stadium",
                date: Date().addingTimeInterval(86400 * 56), // 8 weeks
                minPrice: 110.0,
                maxPrice: 220.0,
                genre: "Pop Rock",
                source: "manual",
                externalID: "hs-love-1"
            )
        ]
        
        // Upload each concert to Firestore
        for concert in sampleConcerts {
            try await concertRepository.createConcert(concert)
        }
        
        print("✅ Seeded \(sampleConcerts.count) sample concerts!")
    }
}
