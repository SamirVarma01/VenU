//
//  User.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: String
    var email: String
    var displayName: String
    var schoolID: String
    var profileImageURL: String?
    var isEmailVerified: Bool
    var isProfilePublic: Bool
    var createdAt: Date
    var bio: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade) var concertAttendances: [ConcertAttendance]?
    @Relationship(deleteRule: .cascade) var friendships: [Friendship]?
    
    init(
        id: String,
        email: String,
        displayName: String,
        schoolID: String,
        profileImageURL: String? = nil,
        isEmailVerified: Bool = false,
        isProfilePublic: Bool = true,
        createdAt: Date = Date(),
        bio: String? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.schoolID = schoolID
        self.profileImageURL = profileImageURL
        self.isEmailVerified = isEmailVerified
        self.isProfilePublic = isProfilePublic
        self.createdAt = createdAt
        self.bio = bio
    }
}

// MARK: - Firestore Codable
extension User {
    /// Convert to dictionary for Firestore
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "email": email,
            "displayName": displayName,
            "schoolID": schoolID,
            "profileImageURL": profileImageURL as Any,
            "isEmailVerified": isEmailVerified,
            "isProfilePublic": isProfilePublic,
            "createdAt": createdAt.timeIntervalSince1970,
            "bio": bio as Any
        ]
    }
    
    /// Create from Firestore dictionary
    static func fromFirestore(_ data: [String: Any], id: String) -> User? {
        guard
            let email = data["email"] as? String,
            let displayName = data["displayName"] as? String,
            let schoolID = data["schoolID"] as? String,
            let isEmailVerified = data["isEmailVerified"] as? Bool,
            let isProfilePublic = data["isProfilePublic"] as? Bool,
            let createdAtTimestamp = data["createdAt"] as? TimeInterval
        else {
            return nil
        }
        
        return User(
            id: id,
            email: email,
            displayName: displayName,
            schoolID: schoolID,
            profileImageURL: data["profileImageURL"] as? String,
            isEmailVerified: isEmailVerified,
            isProfilePublic: isProfilePublic,
            createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
            bio: data["bio"] as? String
        )
    }
}
