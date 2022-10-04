//
//  Message.swift
//  Grinder
//
//  Created by Beavean on 03.10.2022.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class Message {
    
    var id = ""
    var chatRoomID = ""
    var senderID = ""
    var senderName = ""
    var type = ""
    var isIncoming = false
    var sentDate = Date()
    var message = ""
    var photoWidth = 0
    var photoHeight = 0
    var senderInitials = ""
    var mediaURL = ""
    var status = ""
    
    var dictionary: NSDictionary {
        return NSDictionary(objects: [
            self.id,
            self.chatRoomID,
            self.senderID,
            self.senderName,
            self.type,
            self.isIncoming,
            self.sentDate,
            self.message,
            self.photoWidth,
            self.photoHeight,
            self.senderInitials,
            self.mediaURL,
            self.status
        ], forKeys: [
            K.objectID as NSCopying,
            K.chatRoomID as NSCopying,
            K.senderID as NSCopying,
            K.senderName as NSCopying,
            K.type as NSCopying,
            K.date as NSCopying,
            K.message as NSCopying,
            K.photoWidth as NSCopying,
            K.photoHeight as NSCopying,
            K.senderInitials as NSCopying,
            K.mediaURL as NSCopying,
            K.status as NSCopying
        ])
    }
    
    init() { }
    
    init(dictionary: [String: Any]) {
        id = dictionary[K.objectID] as? String ?? ""
        chatRoomID = dictionary[K.chatRoomID] as? String ?? ""
        senderID = dictionary[K.senderID] as? String ?? ""
        senderName = dictionary[K.senderName] as? String ?? ""
        type = dictionary[K.type] as? String ?? ""
        isIncoming = (dictionary[K.senderID] as? String ?? "") != FirebaseUser.currentID()
        sentDate = (dictionary[K.date] as? Timestamp)?.dateValue() ?? Date()
        message = dictionary[K.message] as? String ?? ""
        photoWidth = dictionary[K.photoWidth] as? Int ?? 0
        photoHeight = dictionary[K.photoHeight] as? Int ?? 0
        senderInitials = dictionary[K.senderInitials] as? String ?? ""
        mediaURL = dictionary[K.mediaURL] as? String ?? ""
        status = dictionary[K.status] as? String ?? ""
    }
    
}
