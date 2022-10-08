//
//  SceneDelegate.swift
//  Grinder
//
//  Created by Beavean on 20.09.2022.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        autoLogin()
    }

    //MARK: - Autologin
    
    func autoLogin() {
        authListener = Auth.auth().addStateDidChangeListener({ auth, user in
            guard let authListener = self.authListener else { return }
            Auth.auth().removeStateDidChangeListener(authListener)
            if let user = user, let currentUser = K.userDefaults.object(forKey: K.currentUser) {
                DispatchQueue.main.async {
                    self.enterApplication()
                }
            }
        })
    }
    
    private func enterApplication() {
        guard let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.mainViewIdentifier) as? UITabBarController else { return }
        self.window?.rootViewController = mainView
    }
}

