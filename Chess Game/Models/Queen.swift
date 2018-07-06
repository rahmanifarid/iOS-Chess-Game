//
//  Queen.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class Queen:SlidingPiece{
    private let symbols = [PieceColor.White: "\u{2655}", PieceColor.Black: "\u{265B}"]
    override var symbol:String{
        get{
            return symbols[color]!
        }
    }
    override func possibleMoves(onBoard board: ChessBoard) -> [Move]? {
        var moves = [Move]()
        moves += slidingMoves(board: board, rowParameter: 0, columnParameter: 1)
        moves += slidingMoves(board: board, rowParameter: 0, columnParameter: -1)
        moves += slidingMoves(board: board, rowParameter: -1, columnParameter: 0)
        moves += slidingMoves(board: board, rowParameter: 1, columnParameter: 0)
        moves += slidingMoves(board: board, rowParameter: 1, columnParameter: 1)
        moves += slidingMoves(board: board, rowParameter: -1, columnParameter: -1)
        moves += slidingMoves(board: board, rowParameter: -1, columnParameter: 1)
        moves += slidingMoves(board: board, rowParameter: 1, columnParameter: -1)
        return moves.count > 0 ? moves : nil
    }
}
