//
//  IncomingMessage.swift
//  Grinder
//
//  Created by Beavean on 06.10.2022.
//

import Foundation
import MessageKit
import FirebaseStorage

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(collectionView: MessagesViewController) {
        messageCollectionView = collectionView
    }
    
    func createMessage(messageDictionary: [String: Any]) -> MKMassage? {
        let message = Message(dictionary: messageDictionary)
        let mkMessage = MKMassage(message: message)
        if message.type == K.picture {
            print("DEBUG: This is a picture message")
        }
        return mkMessage
    }
}
