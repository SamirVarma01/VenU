//
//  ConcertAttendance.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData

@Model
final class ConcertAttendance {
    @Attribute(.unique) var id: String
    var userID: String
    var concertID: String
    var isPublic: Bool
    var hasBoughtTickets: Bool
    var ticketPurchaseDate: Date?
    var sectionNumber: String?
    var seatNumber: String?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    var user: User?
    var concert: Concert?
    
    init(
        id: String = UUID().uuidString,
        userID: String,
        concertID: String,
        isPublic: Bool = true,
        hasBoughtTickets: Bool = false,
        ticketPurchaseDate: Date? = nil,
        sectionNumber: String? = nil,
        seatNumber: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userID = userID
        self.concertID = concertID
        self.isPublic = isPublic
        self.hasBoughtTickets = hasBoughtTickets
        self.ticketPurchaseDate = ticketPurchaseDate
        self.sectionNumber = sectionNumber
        self.seatNumber = seatNumber
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Firestore Codable
extension ConcertAttendance {
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "userID": userID,
            "concertID": concertID,
            "isPublic": isPublic,
            "hasBoughtTickets": hasBoughtTickets,
            "ticketPurchaseDate": ticketPurchaseDate?.timeIntervalSince1970 as Any,
            "sectionNumber": sectionNumber as Any,
            "seatNumber": seatNumber as Any,
            "notes": notes as Any,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
    }
    
    static func fromFirestore(_ data: [String: Any], id: String) -> ConcertAttendance? {
        guard
            let userID = data["userID"] as? String,
            let concertID = data["concertID"] as? String,
            let isPublic = data["isPublic"] as? Bool,
            let hasBoughtTickets = data["hasBoughtTickets"] as? Bool,
            let createdAtTimestamp = data["createdAt"] as? TimeInterval,
            let updatedAtTimestamp = data["updatedAt"] as? TimeInterval
        else {
            return nil
        }
        
        let ticketPurchaseDate: Date?
        if let timestamp = data["ticketPurchaseDate"] as? TimeInterval {
            ticketPurchaseDate = Date(timeIntervalSince1970: timestamp)
        } else {
            ticketPurchaseDate = nil
        }
        
        return ConcertAttendance(
            id: id,
            userID: userID,
            concertID: concertID,
            isPublic: isPublic,
            hasBoughtTickets: hasBoughtTickets,
            ticketPurchaseDate: ticketPurchaseDate,
            sectionNumber: data["sectionNumber"] as? String,
            seatNumber: data["seatNumber"] as? String,
            notes: data["notes"] as? String,
            createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
            updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
        )
    }
}
