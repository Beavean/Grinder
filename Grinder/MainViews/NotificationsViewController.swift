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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadLikes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsTableView.tableFooterView = UIView()
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
    
    //MARK: - Navigation
    
    private func showUserProfileFor(user: FirebaseUser) {
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.userProfileControllerIdentifier) as! UserProfileTableViewController
        profileView.userObject = user
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}

//MARK: - UITableViewDataSource

extension NotificationsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.likeTableViewCellIdentifier, for: indexPath) as? LikeTableViewCell else { return UITableViewCell() }
        cell.setupCell(user: allUsers[indexPath.row])
        return cell
    }
}

//MARK: - UITableViewDelegate

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showUserProfileFor(user: allUsers[indexPath.row])
    }
}

