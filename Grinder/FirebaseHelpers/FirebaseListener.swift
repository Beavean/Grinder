//
//  FirebaseListener.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class FirebaseListener {
    
    static let shared = FirebaseListener()
    
    private init() {}
    
    //MARK: - Download users
    
    func downloadUsersFromFirebase(isInitialLoad: Bool, limit: Int, lastDocumentSnapshot: DocumentSnapshot?, completion: @escaping (_ users: [FirebaseUser], _ snapshot: DocumentSnapshot?) -> Void) {
        
    }
    
    //MARK: - Current user
    
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
