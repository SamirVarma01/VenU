//
//  Concert.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData

@Model
final class Concert {
    @Attribute(.unique) var id: String
    var name: String
    var artistName: String
    var venueID: String
    var venueName: String
    var date: Date
    var imageURL: String?
    var ticketURL: String?
    var minPrice: Double?
    var maxPrice: Double?
    var currency: String
    var genre: String?
    
    // Metadata
    var source: String // "ticketmaster", "seatgeek", etc.
    var externalID: String // ID from the source API
    var lastUpdated: Date
    
    // Relationships
    @Relationship(deleteRule: .cascade) var attendances: [ConcertAttendance]?
    
    init(
        id: String,
        name: String,
        artistName: String,
        venueID: String,
        venueName: String,
        date: Date,
        imageURL: String? = nil,
        ticketURL: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        currency: String = "USD",
        genre: String? = nil,
        source: String,
        externalID: String,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.artistName = artistName
        self.venueID = venueID
        self.venueName = venueName
        self.date = date
        self.imageURL = imageURL
        self.ticketURL = ticketURL
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.currency = currency
        self.genre = genre
        self.source = source
        self.externalID = externalID
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Computed Properties
extension Concert {
    var priceRange: String? {
        guard let min = minPrice, let max = maxPrice else { return nil }
        return "$\(Int(min)) - $\(Int(max))"
    }
    
    var isPast: Bool {
        date < Date()
    }
}

// MARK: - Firestore Codable
extension Concert {
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "artistName": artistName,
            "venueID": venueID,
            "venueName": venueName,
            "date": date.timeIntervalSince1970,
            "imageURL": imageURL as Any,
            "ticketURL": ticketURL as Any,
            "minPrice": minPrice as Any,
            "maxPrice": maxPrice as Any,
            "currency": currency,
            "genre": genre as Any,
            "source": source,
            "externalID": externalID,
            "lastUpdated": lastUpdated.timeIntervalSince1970
        ]
    }
    
    static func fromFirestore(_ data: [String: Any], id: String) -> Concert? {
        guard
            let name = data["name"] as? String,
            let artistName = data["artistName"] as? String,
            let venueID = data["venueID"] as? String,
            let venueName = data["venueName"] as? String,
            let dateTimestamp = data["date"] as? TimeInterval,
            let source = data["source"] as? String,
            let externalID = data["externalID"] as? String,
            let lastUpdatedTimestamp = data["lastUpdated"] as? TimeInterval
        else {
            return nil
        }
        
        return Concert(
            id: id,
            name: name,
            artistName: artistName,
            venueID: venueID,
            venueName: venueName,
            date: Date(timeIntervalSince1970: dateTimestamp),
            imageURL: data["imageURL"] as? String,
            ticketURL: data["ticketURL"] as? String,
            minPrice: data["minPrice"] as? Double,
            maxPrice: data["maxPrice"] as? Double,
            currency: data["currency"] as? String ?? "USD",
            genre: data["genre"] as? String,
            source: source,
            externalID: externalID,
            lastUpdated: Date(timeIntervalSince1970: lastUpdatedTimestamp)
        )
    }
}
