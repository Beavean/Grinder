//
//  GlobalFunctions.swift
//  Grinder
//
//  Created by Beavean on 28.09.2022.
//

import Foundation
import FirebaseFirestore

//MARK: - Matches

func removeCurrentUserID(userIDs: [String]) -> [String] {
    var allIDs = userIDs
    for id in allIDs {
        if id == FirebaseUser.currentID() {
            allIDs.remove(at: allIDs.firstIndex(of: id)!)
        }
    }
    return allIDs
}

//MARK: - Save like to user

func saveLikeToUser(userID: String?) {
    guard let userID = userID else { return }
    let like = LikedObject(id: UUID().uuidString, userID: FirebaseUser.currentID(), likedUserID: userID, date: Date())
    like.saveToFirestore()
    if let currentUser = FirebaseUser.currentUser(), var likedArray = currentUser.likedUsersArray {
        if !didLikeUserWith(userID: userID) {
            likedArray.append(userID)
            currentUser.updateCurrentUserInFireStore(withValues: [K.likedUsersArray: likedArray]) { error in
                print("DEBUG: Updated current with error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

//MARK: - Like

func didLikeUserWith(userID: String) -> Bool {
    return FirebaseUser.currentUser()?.likedUsersArray?.contains(userID) ?? false
}

//MARK: - Starting chat

func startChat(user1: FirebaseUser, user2: FirebaseUser) -> String {
    let chatRoomID = chatRoomIDFrom(user1ID: user1.objectID, user2ID: user2.objectID)
    createRecentItems(chatRoomID: chatRoomID, users: [user1, user2])
    return chatRoomID
}

func chatRoomIDFrom(user1ID: String, user2ID: String) -> String {
    var chatRoomID = String()
    let value = user1ID.compare(user2ID).rawValue
    chatRoomID = value < 0 ? user1ID + user2ID : user2ID + user1ID
    return chatRoomID
}

func restartChat(chatRoomID: String, memberIDs: [String]) {
    FirebaseListener.shared.downloadUsersFromFirestore(withIDs: memberIDs) { users in
        if !users.isEmpty {
            createRecentItems(chatRoomID: chatRoomID, users: users)
        }
    }
}


//MARK: - Recent chats

func createRecentItems(chatRoomID: String, users: [FirebaseUser]) {
    var memberIDsToCreateRecent = [String]()
    for user in users {
        memberIDsToCreateRecent.append(user.objectID)
    }
    FirebaseReference(.Recent).whereField(K.chatRoomID, isEqualTo: chatRoomID).getDocuments { snapshot, error in
        guard let snapshot = snapshot else { return }
        if !snapshot.isEmpty {
            memberIDsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIDs: memberIDsToCreateRecent)
        }
        for userID in memberIDsToCreateRecent {
            let senderUser = userID == FirebaseUser.currentID() ? FirebaseUser.currentUser()! : getReceiverFrom(users: users)
            let receiverUser = userID == FirebaseUser.currentID() ? getReceiverFrom(users: users) : FirebaseUser.currentUser()!
            let recentObject = RecentChat()
            recentObject.objectID = UUID().uuidString
            recentObject.chatRoomID = chatRoomID
            recentObject.senderID = senderUser.objectID
            recentObject.senderName = senderUser.username
            recentObject.receiverID = receiverUser.objectID
            recentObject.receiverName = receiverUser.username
            recentObject.date = Date()
            recentObject.memberIDs = [senderUser.objectID, receiverUser.objectID]
            recentObject.lastMessage = ""
            recentObject.unreadCounter = 0
            recentObject.avatarLink = receiverUser.avatarLink
            recentObject.saveToFireStore()
        }
    }
}

func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIDs: [String]) -> [String] {
    var memberIDsToCreateRecent = memberIDs
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserID = currentRecent[K.senderID] {
            if memberIDsToCreateRecent.contains(currentUserID as! String) {
                let index = memberIDsToCreateRecent.firstIndex(of: currentUserID as! String)!
                memberIDsToCreateRecent.remove(at: index)
            }
        }
    }
    return memberIDsToCreateRecent
}

func getReceiverFrom(users: [FirebaseUser]) -> FirebaseUser {
    var allUsers = users
    allUsers.remove(at: allUsers.firstIndex(of: FirebaseUser.currentUser()!)!)
    return allUsers.first!
}
