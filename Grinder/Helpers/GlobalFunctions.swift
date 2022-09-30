//
//  GlobalFunctions.swift
//  Grinder
//
//  Created by Beavean on 28.09.2022.
//

import Foundation

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
    guard let userID = userID, let currentUserID = FirebaseUser.currentID() else { return }
    let like = LikedObject(id: UUID().uuidString, userID: currentUserID, likedUserID: userID, date: Date())
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
