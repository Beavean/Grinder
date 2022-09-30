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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadMatches()
    }
    
    //MARK: - Download
    
    private func downloadMatches() {
        FirebaseListener.shared.downloadUserMatches { matchUserIDs in
            
        }
    }
}

extension RecentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

extension RecentViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
}
