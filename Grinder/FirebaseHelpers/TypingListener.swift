//
//  TypingListener.swift
//  Grinder
//
//  Created by Beavean on 07.10.2022.
//

import Foundation
import FirebaseFirestore

class TypingListener {
    
    static let shared = TypingListener()
    
    var typingListener: ListenerRegistration!
    
    private init() { }
    
    func createTypingObserver(chatRoomID: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        typingListener = FirebaseReference(.Typing).document(chatRoomID).addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != FirebaseUser.currentID() {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                if let currentID = FirebaseUser.currentID() {
                    FirebaseReference(.Typing).document(chatRoomID).setData([currentID: false])
                }
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomID: String) {
        FirebaseReference(.Typing).document(chatRoomID).updateData([FirebaseUser.currentID(): typing])
    }
}
