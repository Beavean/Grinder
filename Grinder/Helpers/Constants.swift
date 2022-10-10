//
//  Constants.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import Foundation

struct K {
    
    static let fileReference = "gs://grinder-e5ee5.appspot.com"
    static let serverKey = "AAAASky3yqU:APA91bGjr_9YqxEWIGE1EhYEMlkqOGo3XAAmWRcEfYKKFJ1B6Jvk0G6g5fRhFGmT6UM0D-soOIFXKP3j_miVxtpH9ZOIZEjcNhTicj3z7ieZs7RyLVJBvRzdLhQ3LPcIcqFXAFO1kMI0"
    
    //MARK: - User defaults
    static let userDefaults = UserDefaults.standard
    static let age = "age"
    static let ageFrom = "ageFrom"
    static let ageTo = "ageTo"


    //MARK: - FirebaseUser
    
    static let objectID = "objectID"
    static let email = "email"
    static let username = "username"
    static let dateOfBirth = "dateOfBirth"
    static let isMale = "isMale"
    static let profession = "profession"
    static let jobTitle = "jobTitle"
    static let about = "about"
    static let city = "city"
    static let country = "country"
    static let height = "height"
    static let lookingFor = "lookingFor"
    static let avatarLink = "avatarLink"
    static let likedUsersArray = "likedUsersArray"
    static let imageLinks = "imageLinks"
    static let registeredDate = "registeredDate"
    static let pushID = "pushID"
    static let currentUser = "currentUser"
    
    //MARK: - User match
    
    static let likingUserID = "userID"
    static let date = "date"
    static let likedUserID = "likedUserID"
    static let memberIDs = "memberIDs"

    
    //MARK: - Storyboard Identifiers
    
    static let mainViewIdentifier = "MainView"
    static let loginViewIdentifier = "LoginView"
    static let userProfileControllerIdentifier = "UserProfileTableViewController"
    static let imageCollectionViewCellIdentifier = "ImageCollectionViewCell"
    static let likeTableViewCellIdentifier = "LikeTableViewCell"
    static let matchViewIdentifier = "MatchViewController"
    static let newMatchCollectionViewCellIdentifier = "NewMatchCollectionViewCell"
    static let recentTableViewCellIdentifier = "RecentTableViewCell"
    
    //MARK: - Recents
    
    static let chatRoomID = "chatRoomID"
    static let senderID = "senderID"
    static let senderName = "senderName"
    static let receiverID = "receiverID"
    static let receiverName = "receiverName"
    static let lastMessage = "lastMessage"
    static let unreadCounter = "unreadCounter"

    //MARK: - Messages
    
    static let type = "type"
    static let message = "message"
    static let photoWidth = "photoWidth"
    static let photoHeight = "photoHeight"
    static let senderInitials = "senderInitials"
    static let mediaURL = "mediaURL"
    static let status = "status"
    static let text = "text"
    static let picture = "picture"
    static let sent = "Sent"
    static let read = "Read"
    
    //MARK: - Messages numbers
    
    static let numberOfMessagesToLoad = 20
    
}



