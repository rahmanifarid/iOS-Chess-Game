//
//  Models.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
struct Position:Hashable{
    var column:Int
    var row:Int
    
    init?(column:Int, row:Int){
        if column > 7 || column < 0 || row > 7 || row < 0{
            return nil
        }
        self.column = column
        self.row = row
    }
}





