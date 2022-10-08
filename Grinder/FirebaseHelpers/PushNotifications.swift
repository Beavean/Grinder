//
//  PushNotifications.swift
//  Grinder
//
//  Created by Beavean on 08.10.2022.
//

import Foundation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init() { }
    
    func sendPushNotificationTo(userIDs: [String], body: String) {
        FirebaseListener.shared.downloadUsersFromFirestore(withIDs: userIDs) { users in
            for user in users {
                if let pushID = user.pushID {
                    self.sendMessageToUser(to: pushID, title: FirebaseUser.currentUser()!.username, body: body)
                }
            }
        }
    }
    
    private func sendMessageToUser(to token: String, title: String, body: String) {
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")!
        let parametersString: [String: Any] = ["to": token,
                                               "notification": [
                                                "title": title,
                                                "body": body,
                                                "badge": "1",
                                                "sound": "default"
                                               ]]
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody =  try? JSONSerialization.data(withJSONObject: parametersString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(K.serverKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            
        }
        task.resume()
    }
}
