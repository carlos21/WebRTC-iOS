//
//  Message.swift
//  WebRTCMobileDemo
//
//  Created by Carlos Duclos on 6/21/20.
//  Copyright © 2020 Land Gorilla. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation
import UIKit

struct User: SenderType, Equatable {
    
    var senderId: String
    var displayName: String
}

private struct CoordinateItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}

private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}

struct Contact: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
}

struct ChatMessage: MessageType {

    var user: User
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var sender: SenderType {
        return user
    }
    
    var text: String {
        switch self.kind {
        case .text(let text):
            return text
        default:
            return ""
        }
    }
    
    private init(kind: MessageKind, user: User, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(custom: Any?, user: User, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: User, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, user: User, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    init(image: UIImage, user: User, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, user: User, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(location: CLLocation, user: User, messageId: String, date: Date) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }

    init(emoji: String, user: User, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

    init(contact: ContactItem, user: User, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }
    
    init(from dictionary: Dictionary<String, Any>) throws {
        guard let message = dictionary["text"] as? String else {
            throw ChatError.message
        }
        guard let userId = dictionary["userId"] as? String else {
            throw ChatError.message
        }
        guard let displayName = dictionary["displayName"] as? String else {
            throw ChatError.message
        }
        self.init(kind: .text(message),
                  user: User(senderId: userId, displayName: displayName),
                  messageId: UUID().uuidString,
                  date: Date())
    }
}
