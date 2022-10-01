//
//  ChatViewController.swift
//  Grinder
//
//  Created by Beavean on 01.10.2022.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import Gallery

class ChatViewController: MessagesViewController {
    
    //MARK: - Properties
    
    private var chatID = String()
    private var recipientID = String()
    private var recipientName = String()
    
    //MARK: - Init
    
    init(chatID: String, recipientID: String, recipientName: String) {
        super.init(nibName: nil, bundle: nil)
        self.chatID = chatID
        self.recipientID = recipientID
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
