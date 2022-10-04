//
//  MessageDefaults.swift
//  Grinder
//
//  Created by Beavean on 04.10.2022.
//

import Foundation
import MessageKit

struct MKSender: SenderType, Equatable {
    
    var senderId: String
    var displayName: String
}

enum MessageDefaults {
    
    //MARK: - Message bubble colors
    
    static let bubbleColorOutgoing = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let bubbleColorIncoming = UIColor(red: 230/255, green: 229/255, blue: 234/255, alpha: 1)

}
