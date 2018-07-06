//
//  Move.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class Move{
    var targetSquare:Position
    var sourceSquare:Position
    var capturedPiece:Piece?
    var chessBoard:ChessBoard
    fileprivate var executed = false
    
    init(withBoard board:ChessBoard, sourceSquare source:Position, targetSquare target:Position) {
        targetSquare = target
        sourceSquare = source
        chessBoard = board
    }
    func execute() {
        if executed{
            print("Already executed")
            return
        }
        let sourcePiece = chessBoard.piece(inPosition: sourceSquare)
        let sideToMove:Piece.PieceColor = sourcePiece.color == .White ? .Black : .White
        movePiece(sourceSquare: sourceSquare, targetSquare: targetSquare)
        
        
        chessBoard.sideToMove = sideToMove
        chessBoard.moves.append(self)
        executed = true
    }
    
    func movePiece(sourceSquare:Position, targetSquare:Position) {
        let sourcePiece = chessBoard.piece(inPosition: sourceSquare)
        sourcePiece.position = targetSquare
        let targetPiece = chessBoard.piece(inPosition: targetSquare)
        if type(of:targetPiece) != NullPiece.self{
            capturedPiece = targetPiece
            capturedPiece?.isCaptured = true
        }
        
        chessBoard.set(position: targetSquare, toPiece: sourcePiece)
        if let king = sourcePiece as? King{
            king.numberOfTimesMoved += 1
        }else if let rook = sourcePiece as? Rook{
            rook.numberOfTimesMoved += 1
        }
        chessBoard.set(position: sourceSquare, toPiece: NullPiece(withColor: Piece.PieceColor.Black, position: sourceSquare))
    }
    
    func undo() {
        if !executed{
            return
        }
        let piece = chessBoard.piece(inPosition: targetSquare)
        undoMove(sourceSquare: sourceSquare, targetSquare: targetSquare)
        chessBoard.sideToMove = piece.color
        chessBoard.moves.removeLast()
        executed = false
    }
    
    func undoMove(sourceSquare:Position, targetSquare:Position) {
        let piece = chessBoard.piece(inPosition: targetSquare)
        piece.position = sourceSquare
        if let king = piece as? King{
            king.numberOfTimesMoved -= 1
        }else if let rook = piece as? Rook{
            rook.numberOfTimesMoved -= 1
        }
        chessBoard.set(position: sourceSquare, toPiece: piece)
        if capturedPiece != nil{
            chessBoard.set(position: targetSquare, toPiece: capturedPiece!)
            capturedPiece?.isCaptured = false
            capturedPiece?.position = targetSquare
        }else{
            chessBoard.set(position: targetSquare, toPiece: NullPiece(withColor: Piece.PieceColor.Black, position: targetSquare))
        }
    }
    
}

class Castle: Move {
    enum CastleType {
        case KingSide
        case QueenSide
    }
    var side:Piece.PieceColor
    var type:CastleType
    init(withBoard board: ChessBoard, side:Piece.PieceColor, castleType:CastleType) {
        self.side = side
        self.type = castleType
        let sourceColumn = 4
        let sourceRow = side == .White ? 0 : 7
        let targetRow = side == .White ? 0 : 7
        let targetColumn = type == .KingSide ? 6 : 2
        super.init(withBoard: board, sourceSquare: Position(column: sourceColumn, row: sourceRow)!, targetSquare: Position(column: targetColumn, row: targetRow)!)
        
    }
    
    override func execute() {
        if executed{
            print("Short castle already executed.")
            return
        }
        let rookSourceColumn = type == .KingSide ? 7 : 0
        let rookTargetColumn = type == .KingSide ? 5 : 3
        let rookPosition = Position(column: rookSourceColumn, row: sourceSquare.row)!
        let rookTargetPosition = Position(column: rookTargetColumn, row: sourceSquare.row)!
        guard let _ = chessBoard.piece(inPosition: sourceSquare) as? King, let _ = chessBoard.piece(inPosition: rookPosition) as? Rook else{
            print("Can't execute short castle move: king or rook not in position.")
            return
        }
        
        let sourcePiece = chessBoard.piece(inPosition: sourceSquare)
        movePiece(sourceSquare: sourceSquare, targetSquare: targetSquare)
        movePiece(sourceSquare: rookPosition, targetSquare: rookTargetPosition)
        
        
        chessBoard.sideToMove = sourcePiece.color == .White ? .Black : .White
        chessBoard.moves.append(self)
        executed = true
        
    }
    
    override func undo() {
        if !executed{
            return
        }
        
        let rookPosition = Position(column: 7, row: sourceSquare.row)!
        let rookTargetPosition = Position(column: 5, row: sourceSquare.row)!
        guard let _ = chessBoard.piece(inPosition: targetSquare) as? King, let _ = chessBoard.piece(inPosition: rookTargetPosition) as? Rook else{
            print("Can't undo short castle move: king or rook not in position.")
            return
        }
        undoMove(sourceSquare: sourceSquare, targetSquare: targetSquare)
        undoMove(sourceSquare: rookPosition, targetSquare: rookTargetPosition)
        
        let piece = chessBoard.piece(inPosition: targetSquare)
        chessBoard.sideToMove = piece.color
        chessBoard.moves.removeLast()
        executed = false
    }
    
    
}


class EnPassantCapture: PawnMove {
    var enPassantSquare:Position
    var enPassantCapturedPawn:Piece?
    override init(withBoard board: ChessBoard, sourceSquare source: Position, targetSquare target: Position) {
        self.enPassantSquare = board.moves.last!.targetSquare
        super.init(withBoard: board, sourceSquare: source, targetSquare: target)
    }
    
    override func execute() {
        super.execute()
        enPassantCapturedPawn = chessBoard.piece(inPosition: enPassantSquare)
        enPassantCapturedPawn?.isCaptured = true
        chessBoard.set(position: enPassantSquare, toPiece: NullPiece(withColor: .Black, position: enPassantSquare))
    }
    
    override func undo() {
        super.undo()
        chessBoard.set(position: enPassantSquare, toPiece: enPassantCapturedPawn!)
        enPassantCapturedPawn?.isCaptured = false
    }
}

class PawnMove: Move {
    
}

class Promotion: Move {
    var promotionPiece:Piece
    var promotedPiece:Piece!
    init(withBoard board: ChessBoard, sourceSquare source: Position, targetSquare target: Position, promotionPiece:Piece) {
        self.promotionPiece = promotionPiece
        super.init(withBoard: board, sourceSquare: source, targetSquare: target)
    }
    override func execute() {
        if executed{
            print("Can't do promotion. It is already executed.")
            return
        }
        promotedPiece = chessBoard.piece(inPosition: sourceSquare)
        promotedPiece.isCaptured = true
        chessBoard.addPiece(promotionPiece, toPosition: sourceSquare)
        super.execute()
    }
    
    override func undo() {
        if !executed{
            print("Can't undo promotion. It is not executed yet.")
            return
        }
        promotedPiece.isCaptured = false
        chessBoard.removePromotedPiece(promotionPiece, fromPosition: targetSquare)
        chessBoard.set(position: targetSquare, toPiece: promotedPiece)
        promotedPiece = nil
        super.undo()
    }
}

struct MoveStruct:Hashable {
    var hashValue: Int{
        get{
            return date.hashValue
        }
    }
    
    var date:Date
    var sourcePosition:Position
    var targetPosition:Position
    var moveType:String
    var promotionTo:String?
    static func createWith(data:[String: Any])->MoveStruct{
        let sourcePosition = Position(column: data["sourceColumn"]as! Int, row: data["sourceRow"] as! Int)!
        let targetPosition = Position(column: data["targetColumn"]as! Int, row: data["targetRow"] as! Int)!
        return MoveStruct(date: data["date"] as!Date, sourcePosition: sourcePosition, targetPosition: targetPosition, moveType: data["moveType"]as! String, promotionTo: data["promotionTo"] as? String)
    }
}
