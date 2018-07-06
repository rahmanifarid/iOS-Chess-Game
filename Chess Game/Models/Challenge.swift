//
//  Challenge.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/30/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
import Firebase
struct Challenge{
    var id:String?
    var gameId:String?
    var senderId:String?
    var date:Date?
    var playerPlayingWhite:String?
    
    static func createWith(data:[String:Any])->Challenge{
        let challenge = Challenge(id: data["id"] as? String, gameId: data["gameId"] as? String, senderId: data["senderId"] as? String, date: data["date"] as? Date, playerPlayingWhite: data["playerPlayingWhite"] as? String)
        return challenge
    }
    
    func respond(accepted:Bool) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let userId = delegate.userId!
        let response = ["id": id!, "gameId": gameId!, "accepted": accepted, "senderId": userId, "date": Date(), "playerPlayingWhite":playerPlayingWhite!] as [String : Any]
        Firestore.firestore().collection("challenges").document(senderId!).collection("responses").addDocument(data: response) { (err) in
            if let error = err{
                print(error.localizedDescription)
            }
            print("Response sent")
        }
        Firestore.firestore().collection("challenges").document(userId).collection("pending").document(id!).delete()
    }
    
    
}
