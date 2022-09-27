//
//  LikedObject.swift
//  Grinder
//
//  Created by Beavean on 27.09.2022.
//

import Foundation

struct LikedObject {
    
    let id: String
    let userID: String
    let likedUserID: String
    let date: Date
    
    var dictionary: [String: Any] {
        return [K.objectID: id, K.likingUserID: userID, K.likedUsersArray: likedUserID, K.likeDate: date]
    }
    
    func saveToFirestore() {
        FirebaseReference(.Like).document(self.id).setData(self.dictionary)
    }
    
}
