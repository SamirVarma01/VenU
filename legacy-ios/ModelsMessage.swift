//
//  Message.swift
//  VenU
//
//  Created by Samir Varma on 6/19/26.
//

import Foundation
import SwiftData

enum MessageType: String, Codable {
    case text
    case image
    case concertShare // For sharing concert info
}

@Model
final class Message {
    @Attribute(.unique) var id: String
    var conversationID: String // Could be a friendship ID or group chat ID
    var senderID: String
    var recipientID: String
    var messageType: String // Using String to store enum
    var content: String
    var imageURL: String?
    var concertID: String? // If sharing a concert
    var isRead: Bool
    var createdAt: Date
    
    var type: MessageType {
        get { MessageType(rawValue: messageType) ?? .text }
        set { messageType = newValue.rawValue }
    }
    
    init(
        id: String = UUID().uuidString,
        conversationID: String,
        senderID: String,
        recipientID: String,
        messageType: MessageType = .text,
        content: String,
        imageURL: String? = nil,
        concertID: String? = nil,
        isRead: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conversationID = conversationID
        self.senderID = senderID
        self.recipientID = recipientID
        self.messageType = messageType.rawValue
        self.content = content
        self.imageURL = imageURL
        self.concertID = concertID
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

// MARK: - Helper Methods
extension Message {
    var isSentByCurrentUser: Bool {
        // This will be set based on the current user context
        // For now, return false as placeholder
        return false
    }
}

// MARK: - Firestore Codable
extension Message {
    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "conversationID": conversationID,
            "senderID": senderID,
            "recipientID": recipientID,
            "messageType": messageType,
            "content": content,
            "imageURL": imageURL as Any,
            "concertID": concertID as Any,
            "isRead": isRead,
            "createdAt": createdAt.timeIntervalSince1970
        ]
    }
    
    static func fromFirestore(_ data: [String: Any], id: String) -> Message? {
        guard
            let conversationID = data["conversationID"] as? String,
            let senderID = data["senderID"] as? String,
            let recipientID = data["recipientID"] as? String,
            let messageTypeString = data["messageType"] as? String,
            let messageType = MessageType(rawValue: messageTypeString),
            let content = data["content"] as? String,
            let isRead = data["isRead"] as? Bool,
            let createdAtTimestamp = data["createdAt"] as? TimeInterval
        else {
            return nil
        }
        
        return Message(
            id: id,
            conversationID: conversationID,
            senderID: senderID,
            recipientID: recipientID,
            messageType: messageType,
            content: content,
            imageURL: data["imageURL"] as? String,
            concertID: data["concertID"] as? String,
            isRead: isRead,
            createdAt: Date(timeIntervalSince1970: createdAtTimestamp)
        )
    }
}
