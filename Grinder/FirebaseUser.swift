//
//  FirebaseUser.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import FirebaseAuth
import UIKit

class FirebaseUser: Equatable {
    
    static func == (lhs: FirebaseUser, rhs: FirebaseUser) -> Bool {
        lhs.objectID == rhs.objectID
    }
    
    let objectID: String
    var email: String
    var username: String
    var dateOfBirth: Date
    var isMale: Bool
    var avatar: UIImage?
    var profession: String
    var jobTitle: String
    var about: String
    var city: String
    var country: String
    var height: Double
    var lookingFor: String
    var avatarLink: String
    var likedUsersArray: [String]?
    var imageLinks: [String]?
    let registeredDate = Date()
    var pushID: String?
    
    //MARK: - Initialiser
    
    init(_objectID: String, _email: String, _username: String, _city: String, _dateOfBirth: Date, _isMale: Bool, _avatarLink: String = "") {
        self.objectID = _objectID
        self.email = _email
        self.username = _username
        self.dateOfBirth = _dateOfBirth
        self.isMale = _isMale
        profession = ""
        jobTitle = ""
        about = ""
        city = _city
        country = ""
        height = 0.0
        lookingFor = ""
        avatarLink = _avatarLink
        likedUsersArray = []
        imageLinks = []
    }
    
    
    class func registerUserWith(email: String, password: String, username: String, city: String, isMale: Bool, dateOfBirth: Date, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authData, error in
            completion(error)
            if error == nil {
                guard let authData = authData else { return }
                authData.user.sendEmailVerification { error in
                    print("DEBUG: Authentication email verification sent \(String(describing: error?.localizedDescription))")
                }
                let user = FirebaseUser(_objectID: authData.user.uid, _email: email, _username: username, _city: city, _dateOfBirth: dateOfBirth, _isMale: isMale)
                
            }
        }
    }
}
