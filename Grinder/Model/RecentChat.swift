//
//  RecentChat.swift
//  Grinder
//
//  Created by Beavean on 30.09.2022.
//

import UIKit
import FirebaseFirestore

class RecentChat {
    var objectID = ""
    var chatRoomID = ""
    var senderID = ""
    var senderName = ""
    var receiverID = ""
    var receiverName = ""
    var date = Date()
    var memberIDs = [""]
    var lastMessage = ""
    var unreadCounter = 0
    var avatarLink = ""
    
    var avatar: UIImage?
    
    var dictionary: NSDictionary {
        return NSDictionary(objects: [ self.objectID,
                                       self.chatRoomID,
                                       self.senderID,
                                       self.senderName,
                                       self.receiverID,
                                       self.receiverName,
                                       self.date,
                                       self.memberIDs,
                                       self.lastMessage,
                                       self.unreadCounter,
                                       self.avatarLink ],
                            forKeys: [ K.objectID as NSCopying,
                                       K.chatRoomID as NSCopying,
                                       K.senderID as NSCopying,
                                       K.senderName as NSCopying,
                                       K.receiverID as NSCopying,
                                       K.receiverName as NSCopying,
                                       K.date as NSCopying,
                                       K.memberIDs as NSCopying,
                                       K.lastMessage as NSCopying,
                                       K.unreadCounter as NSCopying,
                                       K.avatarLink as NSCopying ])
    }
    
    init() { }
    
    init(_ recentDocument: Dictionary<String, Any>) {
        objectID = recentDocument[K.objectID] as? String ?? ""
        chatRoomID = recentDocument[K.chatRoomID] as? String ?? ""
        senderID = recentDocument[K.senderID] as? String ?? ""
        senderName = recentDocument[K.senderName] as? String ?? ""
        receiverID = recentDocument[K.receiverID] as? String ?? ""
        receiverName = recentDocument[K.receiverName] as? String ?? ""
        date = (recentDocument[K.date] as? Timestamp)?.dateValue() ?? Date()
        memberIDs = recentDocument[K.memberIDs] as? [String] ?? []
        lastMessage = recentDocument[K.lastMessage] as? String ?? ""
        unreadCounter = recentDocument[K.unreadCounter] as? Int ?? 0
        avatarLink = recentDocument[K.avatarLink] as? String ?? ""
    }
    
    //MARK: - Saving
    
    func saveToFireStore() {
        
    }
    
    func deleteRecent() {
        
    }
}
