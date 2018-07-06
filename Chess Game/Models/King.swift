//
//  King.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class King:Piece{
    var numberOfTimesMoved = 0
    private let symbols = [PieceColor.White: "\u{2654}", PieceColor.Black: "\u{265A}"]
    override var symbol:String{
        get{
            return symbols[color]!
        }
    }
    
    override func possibleMoves(onBoard board: ChessBoard) -> [Move]? {
        var moves = [Move]()
        let column = position.column
        let row = position.row
        let parameters = [(1, 0),(-1, 0),(0, 1),(0, -1),(1, 1),(1, -1),(-1, 1),(-1, -1)]
        for (c, r) in parameters{
            if let targetPosition = Position(column: column + c, row: row + r), (type(of:board.piece(inPosition: targetPosition)) == NullPiece.self || board.piece(inPosition: targetPosition).color != color){
                let move = Move(withBoard: board, sourceSquare: position, targetSquare: targetPosition)
                moves.append(move)
            }
        }
        
        
        return moves.count > 0 ? moves : nil
    }
    
    
    override func validMoves(onBoard board: ChessBoard) -> [Move]? {
        guard var moves = super.validMoves(onBoard: board) else{
            return nil
        }
        
        if board.isKingInCheck(pieceColor: color){
            return moves
        }
        if board.hasCastlingRight(color: color, toSide: .KingSide){
            let isRightSideClear = type(of: board.piece(inPosition: Position(column: 5, row: self.position.row)!)) == NullPiece.self && type(of: board.piece(inPosition: Position(column: 6, row: self.position.row)!)) == NullPiece.self
            if isRightSideClear{
                let move = Move(withBoard: board, sourceSquare: self.position, targetSquare: Position(column: 5, row: self.position.row)!)
                move.execute()
                if !board.isKingInCheck(pieceColor: color){
                    let castle = Castle(withBoard: board, side: color, castleType: .KingSide)
                    moves.append(castle)
                }
                move.undo()
            }
        }
        
        if board.hasCastlingRight(color: color, toSide: .QueenSide){
            let isLeftSideClear = type(of: board.piece(inPosition: Position(column: 3, row: self.position.row)!)) == NullPiece.self && type(of: board.piece(inPosition: Position(column: 2, row: self.position.row)!)) == NullPiece.self && type(of: board.piece(inPosition: Position(column: 1, row: self.position.row)!)) == NullPiece.self
            if isLeftSideClear{
                let move = Move(withBoard: board, sourceSquare: self.position, targetSquare: Position(column: 3, row: self.position.row)!)
                move.execute()
                if !board.isKingInCheck(pieceColor: color){
                    let castle = Castle(withBoard: board, side: color, castleType: .QueenSide)
                    moves.append(castle)
                }
                move.undo()
            }
        }
        
        return moves
        
    }
}
