//
//  User.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/27/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//
import Firebase
import FirebaseStorageUI
import UIKit
@objcMembers class User:NSObject{
    dynamic var name: String?
    var profileUrl: String?
    var id: String?
    dynamic var profileImage:UIImage?
    dynamic var imageDownloaded = false
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? User, other.id == self.id{
            return true
        }
        return false
    }
    init(name:String?, profileUrl:String?, id:String?){
        self.name = name
        self.id = id
        self.profileUrl = profileUrl
        super.init()
        
    }
    
    convenience init(withUserId id:String){
        self.init(name: nil, profileUrl: nil, id: id)
        startObservering()
    }
    
    deinit {
        observer?.remove()
    }
    func startDownloadingData() {
        
        startObservering()
    }
    
    var alreadyObserving = false
    var observer:ListenerRegistration?
    func startObservering() {
        if let userId = id, alreadyObserving == false{
            alreadyObserving = true
            observer = Firestore.firestore().collection("users").document(userId).addSnapshotListener({ (ss, err) in
                if let error = err{
                    print(error.localizedDescription)
                }
                
                if let snapshot = ss{
                    if let data = snapshot.data(){
                        print("User info changed. Data: \(data)")
                        self.name = data["name"] as? String
                        if self.profileUrl != data["profileURL"] as? String{
                            self.profileUrl = data["profileURL"] as? String
                            self.downloadProfileImage()
                        }
                        
                    }
                    
                }
            })
        }
    }
    var profileImageDownloadError = false
    func downloadProfileImage(){
        if profileUrl == nil{
            return
        }
        let url = URL(string:profileUrl!)
        SDWebImageDownloader.shared().downloadImage(with: url, options: SDWebImageDownloaderOptions.continueInBackground, progress: { (downloaded, remaining, url) in
            DispatchQueue.main.async {
                //                self.profilePicPercent = Float(100 * downloaded / remaining)
                //                print("\(100 * downloaded / remaining)")
            }
        }) { (img, data, err, completed) in
            DispatchQueue.main.async {
                if err != nil {
                    self.profileImageDownloadError = true
                    print("Error downloading profile image")
                }
                if let image = img{
                    self.profileImage = image
                    self.imageDownloaded = true
                    print("Completed profile download successfully")
                }
            }
        }
    }
    
    func stopObserving(){
        observer?.remove()
        alreadyObserving = false
    }
    static func createWith(data:[String : Any]) -> User{
        return User(name: data["name"] as? String, profileUrl: data["profileURL"] as? String, id: data["id"] as? String)
    }
    
}
