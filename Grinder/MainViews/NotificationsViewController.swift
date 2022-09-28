//
//  NotificationsViewController.swift
//  Grinder
//
//  Created by Beavean on 28.09.2022.
//

import UIKit
import ProgressHUD

class NotificationsViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var notificationsTableView: UITableView!
    
    //MARK: - Properties
    
    var allLikes = [LikedObject]()
    var allUsers = [FirebaseUser]()

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadLikes()
    }
    
    //MARK: - Download user likes
    
    private func downloadLikes() {
        ProgressHUD.show()
        FirebaseListener.shared.downloadUserLikes { likedUserIDs in
            if likedUserIDs.count > 0 {
                FirebaseListener.shared.downloadUsersFromFirestore(withIDs: likedUserIDs) { users in
                    ProgressHUD.dismiss()
                    self.allUsers = users
                    DispatchQueue.main.async {
                        self.notificationsTableView.reloadData()
                    }
                }
            } else {
                ProgressHUD.dismiss()
            }
        }
    }
}

extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension NotificationsViewController: UITableViewDelegate {
    
}
