//
//  RecentViewController.swift
//  Grinder
//
//  Created by Beavean on 30.09.2022.
//

import UIKit

class RecentViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var newMatchesCollectionView: UICollectionView!
    @IBOutlet weak var messagesTableView: UITableView!
    
    //MARK: - Properties
    
    var recentMatches = [FirebaseUser]()
    var recentChats = [RecentChat]()
    
    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadMatches()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRecents()
    }
    
    //MARK: - Download
    
    private func downloadMatches() {
        FirebaseListener.shared.downloadUserMatches { matchUserIDs in
            if !matchUserIDs.isEmpty {
                FirebaseListener.shared.downloadUsersFromFirestore(withIDs: matchUserIDs) { users in
                    self.recentMatches = users
                    DispatchQueue.main.async {
                        self.newMatchesCollectionView.reloadData()
                    }
                }
            } else {
                print("DEBUG: No matches")
            }
        }
    }
    
    private func downloadRecents() {
        FirebaseListener.shared.downloadRecentChatsFromFirestore { allRecentItems in
            self.recentChats = allRecentItems
            DispatchQueue.main.async {
                self.messagesTableView.reloadData()
            }
        }
    }
    
    //MARK: - Navigation
    
    private func showUserProfileFor(user: FirebaseUser) {
        let profileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: K.userProfileControllerIdentifier) as! UserProfileTableViewController
        profileView.userObject = user
        profileView.isMatchedUser = true
        self.navigationController?.pushViewController(profileView, animated: true)
    }
}

extension RecentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.recentTableViewCellIdentifier, for: indexPath) as? RecentTableViewCell else { return UITableViewCell() }
        cell.generateCell(recentChat: recentChats[indexPath.row])
        return cell
    }
}

extension RecentViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !recentMatches.isEmpty ? recentMatches.count : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.newMatchCollectionViewCellIdentifier, for: indexPath) as? NewMatchCollectionViewCell else { return UICollectionViewCell() }
        if !recentMatches.isEmpty {
            cell.setupCell(avatarLink: recentMatches[indexPath.row].avatarLink)
        }
        return cell
    }
}

extension RecentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recent = self.recentChats[indexPath.row]
            recent.deleteRecent()
            self.recentChats.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension RecentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !recentMatches.isEmpty {
            showUserProfileFor(user: recentMatches[indexPath.row])
        }
    }
}
