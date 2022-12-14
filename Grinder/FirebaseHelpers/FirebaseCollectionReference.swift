//
//  FirebaseCollectionReference.swift
//  Grinder
//
//  Created by Beavean on 21.09.2022.
//

import FirebaseFirestore

enum FirebaseCollectionReference: String {
    case User
    case Like
    case Match
    case Recent
    case Messages
    case Typing
}

func FirebaseReference(_ collectionReference: FirebaseCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
}
