//
//  UserCard.swift
//  Grinder
//
//  Created by Beavean on 24.09.2022.
//

import Foundation
import Shuffle_iOS

class UserCard: SwipeCard {
    func configure(withModel model: UserCardModel) {
        content = UserCardContentView(withImage: model.image)
        footer = UserCardFooterView(withTitle: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
}
