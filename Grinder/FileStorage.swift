//
//  FileStorage.swift
//  Grinder
//
//  Created by Beavean on 23.09.2022.
//

import FirebaseStorage

let storage = Storage.storage()

class FileStorage {
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        let storageReference = storage.reference(forURL: K.fileReference).child(directory)
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        task = storageReference.putData(imageData!, metadata: nil, completion: { metaData, error in
            task.removeAllObservers()
            if let error = error {
                print("DEBUG: error uploading image \(error.localizedDescription)")
                return
            }
            storageReference.downloadURL { url, error in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                print("DEBUG: We have uploaded image to  \(downloadUrl)")
                completion(downloadUrl.absoluteString)
            }
        })
    }
}

