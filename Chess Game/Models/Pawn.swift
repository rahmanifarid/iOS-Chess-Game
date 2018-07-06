//
//  Pawn.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class Pawn:Piece{
    
    override func possibleMoves(onBoard board:ChessBoard)->[Move]?{
        var moves = [PawnMove]()
        let nextRowParameter = color == .White ? 1 : -1
        let nextRow = position.row + nextRowParameter
        let hasMoved = color == .White ? position.row != 1 : position.row != 6
        if let nextRowPosition = Position(column: position.column, row: nextRow){
            let pieceOnNextRow = board.piece(inPosition: nextRowPosition)
            if type(of: pieceOnNextRow) == NullPiece.self{
                let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: nextRowPosition)
                moves.append(move)
                
                if !hasMoved{
                    let next2ndRow = Position(column: position.column, row: nextRow + nextRowParameter)!
                    if type(of: board.piece(inPosition: next2ndRow)) == NullPiece.self{
                        let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: next2ndRow)
                        moves.append(move)
                    }
                    
                }
            }
        }
        if let leftDiagnal = Position(column: position.column - 1, row: nextRow){
            let piece = board.piece(inPosition: leftDiagnal)
            if type(of: piece) != NullPiece.self && piece.color != self.color{
                let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: leftDiagnal)
                moves.append(move)
            }
        }
        
        if let rightDiagnal = Position(column: position.column + 1, row: nextRow){
            let piece = board.piece(inPosition: rightDiagnal)
            if type(of: piece) != NullPiece.self && piece.color != self.color {
                let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: rightDiagnal)
                moves.append(move)
            }
        }
        
        let enPassantRow = color == .White ? 4 : 3
        if let lastPawnMove = board.moves.last as? PawnMove,lastPawnMove.targetSquare.row == enPassantRow {
            print("Last move is enPassant")
            if self.position.row == enPassantRow && (lastPawnMove.targetSquare.column == position.column - 1 || lastPawnMove.targetSquare.column == position.column + 1){
                print("Enpassant!!")
                let move = EnPassantCapture(withBoard: board, sourceSquare: position, targetSquare: Position(column: lastPawnMove.targetSquare.column, row: nextRow)!)
                moves.append(move)
                
            }
            
        }
        
        
        
//        if color == .White{
//            if position.row < 7{
//                let nextRank = Position(column:position.column, row:position.row + 1)!
//                let pieceOnNextRank = board.piece(inPosition:nextRank)
//                if type(of:pieceOnNextRank) == NullPiece.self{
//                    let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: nextRank)
//                    moves.append(move)
//                    if position.row == 1{
//                        let fourthRank = Position(column:position.column, row:3)!
//                        let pieceOnFourthRank = board.piece(inPosition:fourthRank)
//                        if type(of:pieceOnFourthRank) == NullPiece.self{
//                            let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: fourthRank)
//                            moves.append(move)
//                        }
//                    }
//                }
//                if let rightDiagonal = Position(column:position.column - 1, row:position.row + 1){
//                    let pieceOnRightDiag = board.piece(inPosition:rightDiagonal)
//                    if type(of:pieceOnRightDiag) != NullPiece.self && pieceOnRightDiag.color != color{
//                        let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: rightDiagonal)
//                        moves.append(move)
//                    }
//                }
//                if let leftDiagonal = Position(column:position.column + 1, row:position.row + 1){
//                    let pieceOnLeftDiag = board.piece(inPosition:leftDiagonal)
//                    if type(of:pieceOnLeftDiag) != NullPiece.self && pieceOnLeftDiag.color != color{
//                        let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: leftDiagonal)
//                        moves.append(move)
//                    }
//                }
//
//
//            }
//
//        }else{
//            if position.row > 0{
//                let nextRank = Position(column:position.column, row:position.row - 1)!
//                let pieceOnNextRank = board.piece(inPosition:nextRank)
//                if type(of:pieceOnNextRank) == NullPiece.self{
//                    let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: nextRank)
//                    moves.append(move)
//                    if position.row == 6{
//                        let fifthRank = Position(column:position.column, row:4)!
//                        let pieceOnFifthRank = board.piece(inPosition:fifthRank)
//                        if type(of:pieceOnFifthRank) == NullPiece.self{
//                            let move = PawnMove(withBoard: board, sourceSquare: position, targetSquare: fifthRank)
//                            moves.append(move)
//                        }
//                    }
//                }
//
//            }
//
//
//            if let rightDiagonal = Position(column:position.column - 1, row:position.row - 1) {
//
//                let pieceOnRightDiag = board.piece(inPosition:rightDiagonal)
//                if type(of:pieceOnRightDiag) != NullPiece.self && pieceOnRightDiag.color != color{
//                    let move = Move(withBoard: board, sourceSquare: position, targetSquare: rightDiagonal)
//                    moves.append(move)
//                }
//            }
//            if let leftDiagonal = Position(column:position.column + 1, row:position.row - 1) {
//
//                let pieceOnLeftDiag = board.piece(inPosition:leftDiagonal)
//                if type(of:pieceOnLeftDiag) != NullPiece.self && pieceOnLeftDiag.color != color{
//                    let move = Move(withBoard: board, sourceSquare: position, targetSquare: leftDiagonal)
//                    moves.append(move)
//                }
//            }
//
//        }
        
        return moves.count > 0 ? moves : nil
    }
    private let symbols = [PieceColor.White: "\u{2659}", PieceColor.Black: "\u{265F}"]
    override var symbol:String{
        get{
            return symbols[color]!
        }
    }
}
