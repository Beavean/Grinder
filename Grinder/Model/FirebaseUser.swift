//
//  FirebaseUser.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import FirebaseAuth
import FirebaseFirestore
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
    var age: Int
    
    var userDictionary: NSDictionary {
        return NSDictionary(objects: [
            self.objectID,
            self.email,
            self.username,
            self.dateOfBirth,
            self.isMale,
            self.profession,
            self.jobTitle,
            self.about,
            self.city,
            self.country,
            self.height,
            self.lookingFor,
            self.avatarLink,
            self.likedUsersArray ?? [],
            self.imageLinks ?? [],
            self.registeredDate,
            self.pushID ?? "",
            self.age
        ], forKeys: [
            K.objectID as NSCopying,
            K.email as NSCopying,
            K.username as NSCopying,
            K.dateOfBirth as NSCopying,
            K.isMale as NSCopying,
            K.profession as NSCopying,
            K.jobTitle as NSCopying,
            K.about as NSCopying,
            K.city as NSCopying,
            K.country as NSCopying,
            K.height as NSCopying,
            K.lookingFor as NSCopying,
            K.avatarLink as NSCopying,
            K.likedUsersArray as NSCopying,
            K.imageLinks as NSCopying,
            K.registeredDate as NSCopying,
            K.pushID as NSCopying,
            K.age as NSCopying
        ])
    }
    
    //MARK: - Initialiser
    
    init(objectID: String, email: String, username: String, city: String, dateOfBirth: Date, isMale: Bool, avatarLink: String = "") {
        self.objectID = objectID
        self.email = email
        self.username = username
        self.dateOfBirth = dateOfBirth
        self.isMale = isMale
        self.profession = ""
        self.jobTitle = ""
        self.about = ""
        self.city = city
        self.country = ""
        self.height = 0.0
        self.lookingFor = ""
        self.avatarLink = avatarLink
        self.likedUsersArray = []
        self.imageLinks = []
        self.age = abs(dateOfBirth.interval(ofComponent: .year, fromDate: Date()))
    }
    
    init(dictionary: NSDictionary) {
        self.objectID = dictionary[K.objectID] as? String ?? ""
        self.email = dictionary[K.email] as? String ?? ""
        self.username = dictionary[K.username] as? String ?? ""
        self.isMale = dictionary[K.isMale] as? Bool ?? true
        self.profession = dictionary[K.profession] as? String ?? ""
        self.jobTitle = dictionary[K.jobTitle] as? String ?? ""
        self.about = dictionary[K.about] as? String ?? ""
        self.city = dictionary[K.city] as? String ?? ""
        self.country = dictionary[K.country] as? String ?? ""
        self.height = dictionary[K.height] as? Double ?? 0.0
        self.lookingFor = dictionary[K.lookingFor] as? String ?? ""
        self.avatarLink = dictionary[K.avatarLink] as? String ?? ""
        self.likedUsersArray = dictionary[K.likedUsersArray] as? [String]
        self.imageLinks = dictionary[K.imageLinks] as? [String]
        self.age = dictionary[K.age] as? Int ?? 18
        if let date = dictionary[K.dateOfBirth] as? Timestamp {
            dateOfBirth = date.dateValue()
        } else {
            dateOfBirth = dictionary[K.dateOfBirth] as? Date ?? Date()
        }
        let placeHolder = isMale ? "mPlaceholder" : "fPlaceholder"
        avatar = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: self.objectID)) ?? UIImage(named: placeHolder)
    }
    
    //MARK: - Returning current user
    
    class func currentID() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> FirebaseUser? {
        guard Auth.auth().currentUser?.uid != nil,
              let userDictionary = K.userDefaults.object(forKey: K.currentUser) as? NSDictionary
        else { return nil }
        return FirebaseUser(dictionary: userDictionary)
    }
    
    func getUserAvatarFromFirestore(completion: @escaping (_ didSet: Bool) -> Void) {
        FileStorage.downloadImage(imageURL: self.avatarLink) { image in
            let placeholder = self.isMale ? "mPlaceholder" : "fPlaceholder"
            self.avatar = image ?? UIImage(named: placeholder)
            completion(true)
        }
    }
    
    //MARK: - Login
    
    class func loginUserWith(email: String, password: String, completion: @escaping(_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let error = error {
                completion(error, false)
            } else {
                if let isEmailVerified = authDataResult?.user.isEmailVerified, isEmailVerified == true {
                    guard let userID = authDataResult?.user.uid, let email = authDataResult?.user.email else { return }
                    FirebaseListener.shared.downloadCurrentUserFromFirebase(userID: userID, email: email)
                    completion(error, true)
                } else {
                    print("DEBUG: Email is not verified.")
                    completion(error, false)
                }
            }
        }
    }
    
    //MARK: - Register
    
    class func registerUserWith(email: String, password: String, username: String, city: String, isMale: Bool, dateOfBirth: Date, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authData, error in
            completion(error)
            if error == nil {
                guard let authData = authData else { return }
                authData.user.sendEmailVerification { error in
                    print("DEBUG: Authentication email verification sent \(String(describing: error?.localizedDescription))")
                }
                let user = FirebaseUser(objectID: authData.user.uid, email: email, username: username, city: city, dateOfBirth: dateOfBirth, isMale: isMale)
                user.saveUserLocally()
            }
        }
    }
    
    //MARK: - Edit user profile
    
    func updateUserEmail(newEmail: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.updateEmail(to: newEmail, completion: { error in
            FirebaseUser.resendVerification(email: newEmail) { error in
                
            }
            completion(error)
        })
    }
    
    //MARK: - Resend links
    
    class func resendVerification(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().currentUser?.reload(completion: { error in
            Auth.auth().currentUser?.sendEmailVerification(completion: { error in
                completion(error)
            })
        })
    }
    
    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    //MARK: - LogOut user
    
    class func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        do {
            try Auth.auth().signOut()
            K.userDefaults.removeObject(forKey: K.currentUser)
            K.userDefaults.synchronize()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    //MARK: - Save user methods
    
    func saveUserLocally() {
        K.userDefaults.set(self.userDictionary as? [String: Any], forKey: K.currentUser)
        K.userDefaults.synchronize()
    }
    
    func saveUserToFireStore() {
        FirebaseReference(.User).document(self.objectID).setData(self.userDictionary as! [String : Any]) { error in
            if let error = error {
                print("DEBUG: Error saving user to Firestore: \(error.localizedDescription)")
            }
        }
    }
    
    //MARK: - Update user methods
    
    func updateCurrentUserInFireStore(withValues: [String: Any], completion: @escaping (_ error: Error?) -> Void) {
        if let dictionary = K.userDefaults.object(forKey: K.currentUser),
           let userObject = (dictionary as? NSDictionary)?.mutableCopy() as? NSMutableDictionary {
            userObject.setValuesForKeys(withValues)
            FirebaseReference(.User).document(FirebaseUser.currentID()).updateData(withValues) { error in
                completion(error)
                if error == nil {
                    FirebaseUser(dictionary: userObject).saveUserLocally()
                }
            }
        }
    }
}

func createUsers() {
    
    let names = ["Jordan", "Roman", "Benji", "Corey", "Chester", "Tom"]
    var imageIndex = 1
    var userIndex = 1
    var isMale = true
    for i in 0...(names.count - 1) {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/_" + "\(id)" + ".jpg"
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { avatarLink in
            let user = FirebaseUser(objectID: id, email: "user\(userIndex)@mail.com", username: names[i], city: "No city", dateOfBirth: Date(), isMale: isMale, avatarLink: avatarLink ?? "")
            isMale.toggle()
            userIndex += 1
            user.saveUserToFireStore()
        }
        imageIndex += 1
        if imageIndex == 16 {
            imageIndex = 1
        }
    }
}
