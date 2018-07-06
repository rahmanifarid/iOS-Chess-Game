//
//  ChessBoard.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class ChessBoard{
    var sideToMove = Piece.PieceColor.White
    var allPieces:[[Piece]]{
        get{
            return piecesOnBoard
        }
        
    }
    private var piecesOnBoard = [[Piece]]()
    var moves:[Move] = []
    init(){
        reset()
    }
    func piece(inPosition position:Position)->Piece{
        return piecesOnBoard[position.row][position.column]
    }
    private var whiteKing:Piece{
        get{
            return whitePieces[4]
        }
    }
    private var blackKing:Piece{
        get{
            return blackPieces[4]
        }
    }
    private var whitePieces = [
        Rook(withColor: Piece.PieceColor.White, position: Position(column: 0, row: 0)!),
        Knight(withColor: Piece.PieceColor.White, position: Position(column: 1, row: 0)!),
        Bishop(withColor: Piece.PieceColor.White, position: Position(column: 2, row: 0)!),
        Queen(withColor: Piece.PieceColor.White, position: Position(column: 3, row: 0)!),
        King(withColor: Piece.PieceColor.White, position: Position(column: 4, row: 0)!),
        Bishop(withColor: Piece.PieceColor.White, position: Position(column: 5, row: 0)!),
        Knight(withColor: Piece.PieceColor.White, position: Position(column: 6, row: 0)!),
        Rook(withColor: Piece.PieceColor.White, position: Position(column: 7, row: 0)!)]
    private var whitePromotedPieces = [Piece]()
    private var blackPieces = [
        Rook(withColor: Piece.PieceColor.Black, position: Position(column: 0, row: 7)!),
        Knight(withColor: Piece.PieceColor.Black, position: Position(column: 1, row: 7)!),
        Bishop(withColor: Piece.PieceColor.Black, position: Position(column: 2, row: 7)!),
        Queen(withColor: Piece.PieceColor.Black, position: Position(column: 3, row: 7)!),
        King(withColor: Piece.PieceColor.Black, position: Position(column: 4, row: 7)!),
        Bishop(withColor: Piece.PieceColor.Black, position: Position(column: 5, row: 7)!),
        Knight(withColor: Piece.PieceColor.Black, position: Position(column: 6, row: 7)!),
        Rook(withColor: Piece.PieceColor.Black, position: Position(column: 7, row: 7)!)]
    private var blackPromotedPieces = [Piece]()
    private let whitePawns:[Piece] = {
        var pawns = [Piece]()
        for i in 0...7{
            let row = 1
            let position = Position(column: i, row: row)!
            pawns.append(Pawn(withColor: Piece.PieceColor.White, position:position))
        }
        return pawns
        
    }()
    private let blackPawns:[Piece] = {
        var pawns = [Piece]()
        for i in 0...7{
            let row = 6
            let position = Position(column: i, row: row)!
            pawns.append(Pawn(withColor: Piece.PieceColor.Black, position:position))
        }
        return pawns
    }()
    
    func reset(){
        sideToMove = Piece.PieceColor.White
        for i in 0...7{
            whitePieces[i].isCaptured = false
            whitePieces[i].position = Position(column: i, row: 0)!
            whitePawns[i].isCaptured = false
            whitePawns[i].position = Position(column: i, row: 1)!
            blackPawns[i].isCaptured = false
            blackPawns[i].position = Position(column: i, row: 6)!
            blackPieces[i].isCaptured = false
            blackPieces[i].position = Position(column: i, row: 7)!
        }
        piecesOnBoard = [
            whitePieces,
            whitePawns,
            Array(repeating:NullPiece(withColor: Piece.PieceColor.Black, position: Position(column: 0, row: 0)!), count: 8),
            Array(repeating:NullPiece(withColor: Piece.PieceColor.Black, position: Position(column: 0, row: 0)!), count: 8),
            Array(repeating:NullPiece(withColor: Piece.PieceColor.Black, position: Position(column: 0, row: 0)!), count: 8),
            Array(repeating:NullPiece(withColor: Piece.PieceColor.Black, position: Position(column: 0, row: 0)!), count: 8),
            blackPawns,
            blackPieces
            
        ]
        
    }
    func hasCastlingRight(color:Piece.PieceColor, toSide type:Castle.CastleType) -> Bool {
        let pieces = color == .White ? whitePieces : blackPieces
        let rookIndex = type == .KingSide ? 7 : 0
        let king = pieces[4] as! King
        let rook = pieces[rookIndex] as! Rook
        return king.numberOfTimesMoved == 0 && rook.numberOfTimesMoved == 0

    }
    
    
    
    func isKingInCheck(pieceColor color:Piece.PieceColor)->Bool{
        let kingPosition:Position
        let opponentPieces:[Piece]
        if color == Piece.PieceColor.White{
            kingPosition = whiteKing.position
            opponentPieces = blackPieces + blackPromotedPieces
        }else{
            kingPosition = blackKing.position
            opponentPieces = whitePieces + whitePromotedPieces
        }
        for piece in opponentPieces{
            if piece.isCaptured{
                continue
            }
            
            if let moves = piece.possibleMoves(onBoard:self), moves.contains(where:{(move)->Bool in
                return move.targetSquare.column == kingPosition.column && move.targetSquare.row == kingPosition.row
            }){
                return true
            }
        }
        switch color{
        case .Black:
            
            if kingPosition.row > 0{
                if let leftDiag = Position(column:kingPosition.column + 1, row:kingPosition.row - 1){
                    let leftDiagPiece = piece(inPosition:leftDiag)
                    if type(of:leftDiagPiece) == Pawn.self && leftDiagPiece.color == Piece.PieceColor.White{
                        return true
                    }
                }
                
                if let rightDiag = Position(column:kingPosition.column - 1, row:kingPosition.row - 1){
                    let rightDiagPiece = piece(inPosition:rightDiag)
                    if type(of:rightDiagPiece) == Pawn.self && rightDiagPiece.color == .White{
                        return true
                    }
                }
                
            }
            
            
            
            
        case .White:
            
            if kingPosition.row < 7{
                if let leftDiag = Position(column:kingPosition.column + 1, row:kingPosition.row + 1){
                    let leftDiagPiece = piece(inPosition:leftDiag)
                    if type(of:leftDiagPiece) == Pawn.self && leftDiagPiece.color == .Black{
                        return true
                    }
                }
                
                if let rightDiag = Position(column:kingPosition.column - 1, row:kingPosition.row + 1){
                    let rightDiagPiece = piece(inPosition:rightDiag)
                    if type(of:rightDiagPiece) == Pawn.self && rightDiagPiece.color == .Black{
                        return true
                    }
                }
                
            }
        }
        
        return false
    }
    
    func set(position:Position, toPiece piece:Piece) {
        piecesOnBoard[position.row][position.column] = piece
        
    }
    
    func addPiece(_ piece:Piece, toPosition position:Position) {
        piecesOnBoard[position.row][position.column] = piece
        if piece.color == .White{
            whitePromotedPieces.append(piece)
        }else{
            blackPromotedPieces.append(piece)
        }
    }
    
    func removePromotedPiece(_ piece:Piece, fromPosition position:Position) {
        piecesOnBoard[position.row][position.column] = NullPiece(withColor: .Black, position: position)
        if piece.color == .White{
            whitePromotedPieces.removeLast()
        }else{
            blackPromotedPieces.removeLast()
        }
    }
    
    func description() -> String{
        var des = ""
        for row in allPieces.reversed(){
            for p in row{
                des += p.symbol
            }
            des += "\n"
        }
        return des
    }
    
    func boardPresentation() -> String {
        var result = ""
        for piece in (whitePieces + whitePromotedPieces + blackPieces + blackPromotedPieces + whitePawns + blackPawns){
            if !piece.isCaptured{
              result.append("\(piece.color)\(piece.symbol)\(piece.position.column)\(piece.position.row)")
            }
            
        }
        //result += "\()"
        
        return result
    }
    
    
}
