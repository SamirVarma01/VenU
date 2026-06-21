//
//  Friendship.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData

enum FriendshipStatus: String, Codable {
    case pending
    case accepted
    case blocked
}

@Model
final class Friendship {
    @Attribute(.unique) var id: String
    var requesterID: String // User who sent the friend request
    var recipientID: String // User who received the request
    var status: String // Using String to store enum raw value for SwiftData
    var createdAt: Date
    var updatedAt: Date
    
    // Relationships
    var user: User?
    
    var friendshipStatus: FriendshipStatus {
        get { FriendshipStatus(rawValue: status) ?? .pending }
        set { status = newValue.rawValue }
    }
    
    init(
        id: String = UUID().uuidString,
        requesterID: String,
        recipientID: String,
        status: FriendshipStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.requesterID = requesterID
        self.recipientID = recipientID
        self.status = status.rawValue
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Helper Methods
extension Friendship {
    /// Check if a specific user is the requester
    func isRequester(_ userID: String) -> Bool {
        return requesterID == userID
    }
    
    /// Get the other user's ID in this friendship
    func otherUserID(for userID: String) -> String {
        return userID == requesterID ? recipientID : requesterID
    }
}

// MARK: - Firestore Codable
extension Friendship {
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "requesterID": requesterID,
            "recipientID": recipientID,
            "status": status,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
    }
    
    static func fromFirestore(_ data: [String: Any], id: String) -> Friendship? {
        guard
            let requesterID = data["requesterID"] as? String,
            let recipientID = data["recipientID"] as? String,
            let statusString = data["status"] as? String,
            let status = FriendshipStatus(rawValue: statusString),
            let createdAtTimestamp = data["createdAt"] as? TimeInterval,
            let updatedAtTimestamp = data["updatedAt"] as? TimeInterval
        else {
            return nil
        }
        
        return Friendship(
            id: id,
            requesterID: requesterID,
            recipientID: recipientID,
            status: status,
            createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
            updatedAt: Date(timeIntervalSince1970: updatedAtTimestamp)
        )
    }
}
