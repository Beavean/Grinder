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
        var query: Query!
        var users = [FirebaseUser]()
        if isInitialLoad {
            query = FirebaseReference(.User).order(by: K.registeredDate, descending: false).limit(to: limit)
            print("DEBUG: Downloading user from first \(limit)")
        } else {
            if let lastDocumentSnapshot = lastDocumentSnapshot {
                query = FirebaseReference(.User).order(by: K.registeredDate, descending: false).limit(to: limit).start(afterDocument: lastDocumentSnapshot)
                print("DEBUG: Next user loading from limit \(limit)")
            } else {
                print("DEBUG: last snapshot is nil")
            }
        }
        if let query = query {
            query.getDocuments { snapShot, error in
                guard let snapShot = snapShot else { return }
                if !snapShot.isEmpty {
                    for userData in snapShot.documents {
                        let userObject = userData.data() as NSDictionary
                        if !(FirebaseUser.currentUser()?.likedUsersArray?.contains(userObject[K.objectID] as! String) ?? false) && FirebaseUser.currentID() != userObject[K.objectID] as? String {
                            users.append(FirebaseUser(dictionary: userObject))
                        }
                    }
                    completion(users, snapShot.documents.last)
                } else {
                    print("DEBUG: No more users to fetch")
                    completion(users, nil)
                }
            }
        } else {
            completion(users, nil)
        }
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
