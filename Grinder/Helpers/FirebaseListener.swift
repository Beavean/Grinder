//
//  FirebaseListener.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import Foundation
import FirebaseCore

class FirebaseListener {
    
    static let shared = FirebaseListener()
    
    private init() {}
    
    //MARK: - FirebaseUser
    
    func downloadCurrentUserFromFirebase(userID: String, email: String) {
        FirebaseReference(.User).document(userID).getDocument { snapshot, error in
            guard let snapshot = snapshot else { return }
            if snapshot.exists {
                let user = FirebaseUser(dictionary: snapshot.data()! as NSDictionary)
                user.saveUserLocally()
                user.getUserAvatarFromFirestore { ifSet in
                    
                }
                
            } else {
                if let user = K.userDefaults.object(forKey: K.currentUser) {
                    FirebaseUser(dictionary: user as! NSDictionary).saveUserToFireStore()
                }
            }
        }
    }
}
