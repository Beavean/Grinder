//
//  Constants.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import Foundation

struct K {
    
    static let userDefaults = UserDefaults.standard
    static let fileReference = "gs://grinder-e5ee5.appspot.com"
    
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
    
    //MARK: - Storyboard Identifiers
    
    static let mainViewIdentifier = "MainView"
    static let loginViewIdentifier = "LoginView"
    static let userProfileControllerIdentifier = "UserProfileTableViewController"
    static let imageCollectionViewCellIdentifier = "ImageCollectionViewCell"
}



