//
//  ChallengeResponse.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/30/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
struct ChallengeResponse {
    var id:String?
    var gameId:String?
    var accepted:Bool?
    var senderId:String?
    var date:Date?
    
    static func createWith(data:[String:Any])->ChallengeResponse{
        let response = ChallengeResponse(id: data["id"] as? String, gameId: data["gameId"] as? String, accepted: data["accepted"] as? Bool, senderId: data["senderId"] as? String, date: data["date"] as? Date)
        return response
    }
}
