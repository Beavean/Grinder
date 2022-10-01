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
    
    func downloadUsersFromFirestore(withIDs: [String], completion: @escaping (_ users: [FirebaseUser]) -> Void) {
        var usersArray = [FirebaseUser]()
        var counter = 0
        for userID in withIDs {
            FirebaseReference(.User).document(userID).getDocument { snapShot, error in
                guard let snapShot = snapShot else { return }
                if snapShot.exists, let dictionary = snapShot.data() as? NSDictionary {
                    let user = FirebaseUser(dictionary: dictionary)
                    usersArray.append(user)
                    counter += 1
                    if counter == withIDs.count {
                        completion(usersArray)
                    }
                } else {
                    completion(usersArray)
                }
            }
        }
    }
    
    //MARK: - Likes
    
    func downloadUserLikes(completion: @escaping (_ likedUserIDs: [String]) -> Void) {
        guard let currentUserID = FirebaseUser.currentID() else { return }
        FirebaseReference(.Like).whereField(K.likedUserID, isEqualTo: currentUserID).getDocuments { snapShot, error in
            var allLikedIDs: [String] = []
            guard let snapShot = snapShot else {
                completion(allLikedIDs)
                return
            }
            if !snapShot.isEmpty {
                for likeDictionary in snapShot.documents {
                    allLikedIDs.append(likeDictionary[K.likingUserID] as? String ?? "")
                }
                completion(allLikedIDs)
            } else {
                print("DEBUG: No likes found")
                completion(allLikedIDs)
            }
        }
    }
    
    func checkIfUserLikedUs(userID: String, completion: @escaping (_ didLike: Bool) -> Void) {
        guard let currentUserID = FirebaseUser.currentID() else { return }
        FirebaseReference(.Like).whereField(K.likedUserID, isEqualTo: currentUserID).whereField(K.likingUserID, isEqualTo: userID).getDocuments { snapShot, error in
            guard let snapShot = snapShot else { return }
            completion(!snapShot.isEmpty)
        }
    }
    
    //MARK: - Match
    
    func downloadUserMatches(completion: @escaping (_ matchUserIDs: [String]) -> Void) {
        let lastMonth = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        guard let currentID = FirebaseUser.currentID() else { return }
        FirebaseReference(.Match).whereField(K.memberIDs, arrayContains: currentID).whereField(K.date, isGreaterThan: lastMonth).order(by: K.date, descending: true).getDocuments { snapshot, error in
            var allMatchIDs = [String]()
            guard let snapshot = snapshot else { return }
            if !snapshot.isEmpty {
                for matchDictionary in snapshot.documents {
                    allMatchIDs += matchDictionary[K.memberIDs] as? [String] ?? [""]
                }
                completion(removeCurrentUserID(userIDs: allMatchIDs))
            } else {
                print("DEBUG: No matches found")
                completion(allMatchIDs)
            }
        }
    }
    
    func saveMatch(userID: String) {
        guard let currentID = FirebaseUser.currentID() else { return }
        let match = MatchObject(id: UUID().uuidString, memberIDs: [currentID, userID], date: Date())
        match.saveToFirestore()
    }
    
    //MARK: - Recent Chats
    
    func downloadRecentChatsFromFirestore(completion: @escaping (_ allRecentItems: [RecentChat]) -> Void) {
        FirebaseReference(.Recent).whereField(K.senderID, isEqualTo: FirebaseUser.currentUser()).addSnapshotListener { querySnapshot, error in
            var recentChats = [RecentChat]()
            guard let snapshot = querySnapshot else { return }
            if !snapshot.isEmpty {
                for recentDocument in snapshot.documents {
                    if recentDocument[K.lastMessage] as! String != "" && recentDocument[K.chatRoomID] != nil && recentDocument[K.objectID] != nil {
                        recentChats.append(RecentChat(recentDocument.data()))
                    }
                }
                recentChats.sort(by: {$0.date > $1.date})
                completion(recentChats)
            } else {
                completion(recentChats)
            }
        }
    }
}
