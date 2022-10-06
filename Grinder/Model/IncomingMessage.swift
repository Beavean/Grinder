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
            let photoItem = PhotoMessage(path: message.mediaURL)
            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            FileStorage.downloadImage(imageURL: messageDictionary[K.mediaURL] as? String ?? "") { image in
                mkMessage.photoItem?.image = image
                DispatchQueue.main.async {
                    self.messageCollectionView.messagesCollectionView.reloadData()
                }
            }
        }
        return mkMessage
    }
}
