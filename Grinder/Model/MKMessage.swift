//
//  MKMessage.swift
//  Grinder
//
//  Created by Beavean on 04.10.2022.
//

import Foundation
import MessageKit

class MKMassage: NSObject, MessageType {
    
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
    var incoming: Bool
    var mksender: MKSender
    var sender: SenderType { return mksender }
    var senderInitials: String
    var photoItem: PhotoMessage?
    var status: String
    
    init(message: Message) {
        self.messageId = message.id
        self.mksender = MKSender(senderId: message.senderID, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        self.senderInitials = message.senderInitials
        self.sentDate = message.sentDate
        self.incoming = FirebaseUser.currentID() != mksender.senderId
    }
}

