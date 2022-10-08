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
    
    init(message: Message, photo: UIImage, photoURL: String, memberIDs: [String]) {
        message.type = K.picture
        message.message = "Picture message"
        message.photoWidth = Int(photo.size.width)
        message.photoHeight = Int(photo.size.height)
        message.mediaURL = photoURL
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
        } else {
            if let photo = photo {
                let fileName = Date().getStringFromDate()
                let fileDirectory = "MediaMessages/Photo/" + "\(chatID)/" + "_\(fileName)" + "jpg"
                FileStorage.saveImageLocally(imageData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
                FileStorage.uploadImage(photo, directory: fileDirectory) { imageUrl in
                    if let imageUrl = imageUrl {
                        let outgoingMessage = OutgoingMessage(message: message, photo: photo, photoURL: imageUrl, memberIDs: memberIDs)
                        outgoingMessage.sendMessage(chatRoomID: chatID, messageID: message.id, memberIDs: memberIDs)
                    }
                }
            }
        }
        PushNotificationService.shared.sendPushNotificationTo(userIDs: removeCurrentUserID(userIDs: memberIDs), body: message.message)
        FirebaseListener.shared.updateRecents(chatRoomID: chatID, lastMessage: message.message)
    }
    
    func sendMessage(chatRoomID: String, messageID: String, memberIDs: [String]) {
        for userID in memberIDs {
            FirebaseReference(.Messages).document(userID).collection(chatRoomID).document(messageID).setData(messageDictionary)
        }
    }
    
    class func updateMessage(withID: String, chatRoomID: String, memberIDs: [String]) {
        let values = [K.status: K.read] as [String: Any]
        for userID in memberIDs {
            FirebaseReference(.Messages).document(userID).collection(chatRoomID).document(withID).updateData(values)
        }
    }
}
