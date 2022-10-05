//
//  OutgoingMessage.swift
//  Grinder
//
//  Created by Beavean on 05.10.2022.
//

import UIKit

class OutgoingMessage {
    
    var messageDictionary: [String: Any]
    
    //MARK: - Initialiser
    
    init(message: Message, text: String, memberIDs: [String]) {
        message.type = K.text
        message.message = text
        messageDictionary = message.dictionary as! [String: Any]
    }
    
    class func send(chatID: String, text: String?, photo: UIImage?, memberIDs: [String]) {
        guard let currentUser = FirebaseUser.currentUser() else { return }
        let message = Message()
        message.id = UUID().uuidString
        message.chatRoomID = chatID
        message.senderID = currentUser.objectID
        message.sentDate = Date()
        message.senderInitials = String(currentUser.username.first!)
        message.status = K.sent
        message.message = text ?? "Picture Message"
        if let text = text {
            let outgoingMessage = OutgoingMessage(message: message, text: text, memberIDs: memberIDs)
            outgoingMessage.sendMessage(chatRoomID: chatID, messageID: message.id, memberIDs: memberIDs)
        }
    }
    
    func sendMessage(chatRoomID: String, messageID: String, memberIDs: [String]) {
        for userID in memberIDs {
            FirebaseReference(.Messages).document(userID).collection(chatRoomID).document(messageID).setData(messageDictionary)
        }
    }
}
