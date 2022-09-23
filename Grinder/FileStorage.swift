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
    
    class func downloadImage(imageURL: String, completion: @escaping (_ image: UIImage?) -> Void) {
        guard let imageFileName = imageURL.components(separatedBy: "_").last?.components(separatedBy: ".").first else { return }
        if fileExistsAt(path: imageFileName) {
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(filename: imageFileName)) {
                completion(contentsOfFile)
            } else {
                print("DEBUG: Could not generate image from local file.")
                completion(nil)
            }
        } else {
            print("DEBUG: Downloading file from  \(imageURL)")
            if !imageURL.isEmpty {
                guard let documentURL = URL(string: imageURL) else { return }
                let downloadQueue = DispatchQueue(label: "downloadQueue")
                downloadQueue.async {
                    if let data = NSData(contentsOf: documentURL) as? Data, let dataNS = NSData(contentsOf: documentURL) {
                        let imageToReturn = UIImage(data: data)
                        FileStorage.saveImageLocally(imageData: dataNS, fileName: imageFileName)
                        completion(imageToReturn)
                    } else {
                        print("DEBUG: No image in database.")
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    class func saveImageLocally(imageData: NSData, fileName: String) {
        guard let documentURL = getDocumentsURL()?.appendingPathComponent(fileName, isDirectory: false) else { return }
        imageData.write(to: documentURL, atomically: true)
    }
}

func getDocumentsURL() -> URL? {
    guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else { return nil }
    return documentURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    guard let fileURL = getDocumentsURL()?.appending(path: filename) else { return "" }
    return fileURL.path()
}

func fileExistsAt(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(filename: path))
}

