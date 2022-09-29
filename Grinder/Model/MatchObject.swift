//
//  MatchObject.swift
//  Grinder
//
//  Created by Beavean on 29.09.2022.
//

import Foundation

struct MatchObject {
    
    let id: String
    let memberIDs: [String]
    let date: Date
    
    var dictionary: [String: Any] {
        return [K.objectID: id, K.memberIDs: memberIDs, K.likeDate: date]
    }
    
    func saveToFirestore() {
        FirebaseReference(.Match).document(self.id).setData(self.dictionary)
    }
    
}
