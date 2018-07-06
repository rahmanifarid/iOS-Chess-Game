//
//  Piece.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class Piece{
    var symbol:String{
        get{
            return " "
        }
    }
    var color:PieceColor
    var position = Position(column:0, row:0)!
    var isCaptured = false
    
    
    
    init(withColor color:PieceColor, position:Position){
        self.color = color
        self.position = position
    }
    
    
    
    func possibleMoves(onBoard board:ChessBoard) -> [Move]? {
        return nil
    }
    func validMoves(onBoard board:ChessBoard)->[Move]?{
        if board.sideToMove != color{
            print("Not \(color)'s Move!")
            return nil
        }
        if let possibleMoves = possibleMoves(onBoard: board){
            
            var validMoves = [Move]()
            for move in possibleMoves{
                
                move.execute()
                let sideThatMoved = board.sideToMove == .White ? PieceColor.Black : PieceColor.White
                if !board.isKingInCheck(pieceColor: sideThatMoved) {
                    validMoves.append(move)
                }
                print(board.description())
                move.undo()
                print(board.description())
            }
            return validMoves.count > 0 ? validMoves : nil
            
        }
        return nil
    }
    
//    func validMovePositions(onBoard board:ChessBoard)->[Position]?{
//        if board.sideToMove != color{
//            return nil
//        }
//        if let possibleMoves = possibleMoves(onBoard: board){
//            
//            var validMovePositions = [Position]()
//            for move in possibleMoves{
//                
//                move.execute()
//                let sideThatMoved = board.sideToMove == .White ? PieceColor.Black : PieceColor.White
//                if !board.isKingInCheck(pieceColor: sideThatMoved) {
//                    validMovePositions.append(move.targetSquare)
//                }
//                
//                move.undo()
//                
//            }
//            return validMovePositions.count > 0 ? validMovePositions : nil
//            
//        }
//        return nil
//    }
    
    enum PieceColor:Int{
        case White
        case Black
    }
    
}

class NullPiece: Piece {
    
}
