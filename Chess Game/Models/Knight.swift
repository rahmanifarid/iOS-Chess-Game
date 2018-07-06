//
//  Knight.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class Knight:Piece{
    private let symbols = [PieceColor.White: "\u{2658}", PieceColor.Black: "\u{265E}"]
    override var symbol:String{
        get{
            return symbols[color]!
        }
    }
    
    override func possibleMoves(onBoard board: ChessBoard) -> [Move]? {
        var moves = [Move]()
        let column = position.column
        let row = position.row
        let parameters = [(1, 2),(1, -2),(-1, 2),(-1, -2),(2, 1),(2, -1),(-2, 1),(-2, -1)]
        for (c, r) in parameters{
            if let targetPosition = Position(column: column + c, row: row + r), (type(of:board.piece(inPosition: targetPosition)) == NullPiece.self || board.piece(inPosition: targetPosition).color != color){
                let move = Move(withBoard: board, sourceSquare: position, targetSquare: targetPosition)
                moves.append(move)
            }
        }
        
        return moves.count > 0 ? moves : nil
    }
}
