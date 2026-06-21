//
//  Venue.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class Venue {
    @Attribute(.unique) var id: String
    var name: String
    var address: String
    var city: String
    var state: String
    var country: String
    var zipCode: String?
    var latitude: Double
    var longitude: Double
    var capacity: Int?
    var imageURL: String?
    
    // Metadata
    var source: String // "ticketmaster", "manual", etc.
    var externalID: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(
        id: String,
        name: String,
        address: String,
        city: String,
        state: String,
        country: String = "USA",
        zipCode: String? = nil,
        latitude: Double,
        longitude: Double,
        capacity: Int? = nil,
        imageURL: String? = nil,
        source: String,
        externalID: String
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.city = city
        self.state = state
        self.country = country
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.capacity = capacity
        self.imageURL = imageURL
        self.source = source
        self.externalID = externalID
    }
}

// MARK: - Firestore Codable
extension Venue {
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "address": address,
            "city": city,
            "state": state,
            "country": country,
            "zipCode": zipCode as Any,
            "latitude": latitude,
            "longitude": longitude,
            "capacity": capacity as Any,
            "imageURL": imageURL as Any,
            "source": source,
            "externalID": externalID
        ]
    }
    
    static func fromFirestore(_ data: [String: Any], id: String) -> Venue? {
        guard
            let name = data["name"] as? String,
            let address = data["address"] as? String,
            let city = data["city"] as? String,
            let state = data["state"] as? String,
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double,
            let source = data["source"] as? String,
            let externalID = data["externalID"] as? String
        else {
            return nil
        }
        
        return Venue(
            id: id,
            name: name,
            address: address,
            city: city,
            state: state,
            country: data["country"] as? String ?? "USA",
            zipCode: data["zipCode"] as? String,
            latitude: latitude,
            longitude: longitude,
            capacity: data["capacity"] as? Int,
            imageURL: data["imageURL"] as? String,
            source: source,
            externalID: externalID
        )
    }
}
