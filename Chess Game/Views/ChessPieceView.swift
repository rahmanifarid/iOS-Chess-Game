//
//  ChessPieceView.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
class ChessPieceView: UIView {
    
    convenience init(frame:CGRect, piece:Piece){
        self.init(frame: frame)
        self.backgroundColor = UIColor.clear
        let label = UILabel(frame: bounds)
        label.text = piece.symbol
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34)
        addSubview(label)
    }
    
    
}
