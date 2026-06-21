//
//  School.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class School {
    @Attribute(.unique) var id: String
    var name: String
    var emailDomain: String // e.g., "stanford.edu"
    var latitude: Double
    var longitude: Double
    var city: String
    var state: String
    var country: String
    
    // Computed property for CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(
        id: String,
        name: String,
        emailDomain: String,
        latitude: Double,
        longitude: Double,
        city: String,
        state: String,
        country: String = "USA"
    ) {
        self.id = id
        self.name = name
        self.emailDomain = emailDomain
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.state = state
        self.country = country
    }
}

// MARK: - Firestore Codable
extension School {
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "emailDomain": emailDomain,
            "latitude": latitude,
            "longitude": longitude,
            "city": city,
            "state": state,
            "country": country
        ]
    }
    
    static func fromFirestore(_ data: [String: Any], id: String) -> School? {
        guard
            let name = data["name"] as? String,
            let emailDomain = data["emailDomain"] as? String,
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double,
            let city = data["city"] as? String,
            let state = data["state"] as? String
        else {
            return nil
        }
        
        return School(
            id: id,
            name: name,
            emailDomain: emailDomain,
            latitude: latitude,
            longitude: longitude,
            city: city,
            state: state,
            country: data["country"] as? String ?? "USA"
        )
    }
}

// MARK: - Sample Data
extension School {
    static let stanford = School(
        id: "stanford",
        name: "Stanford University",
        emailDomain: "stanford.edu",
        latitude: 37.4275,
        longitude: -122.1697,
        city: "Stanford",
        state: "CA"
    )
    
    static let berkeley = School(
        id: "berkeley",
        name: "UC Berkeley",
        emailDomain: "berkeley.edu",
        latitude: 37.8719,
        longitude: -122.2585,
        city: "Berkeley",
        state: "CA"
    )
    
    static let mit = School(
        id: "mit",
        name: "Massachusetts Institute of Technology",
        emailDomain: "mit.edu",
        latitude: 42.3601,
        longitude: -71.0942,
        city: "Cambridge",
        state: "MA"
    )
}
