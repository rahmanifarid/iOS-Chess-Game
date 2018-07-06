//
//  SlidingPiece.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import Foundation
class SlidingPiece: Piece {
    
    func slidingMoves(board:ChessBoard, rowParameter:Int, columnParameter:Int) -> [Move] {
        
        
        var moves = [Move]()
        var column = self.position.column + columnParameter
        var row = self.position.row + rowParameter
        
        while let targetPosition = Position(column: column, row: row)  {
            
            column += columnParameter
            row += rowParameter
            
            let pieceAtTarget = board.piece(inPosition: targetPosition)
            if type(of: pieceAtTarget) == NullPiece.self{
                let move = Move(withBoard: board, sourceSquare: self.position, targetSquare: targetPosition)
                moves.append(move)
                continue
            }
            
            
            if pieceAtTarget.color != self.color{
                let move = Move(withBoard: board, sourceSquare: self.position, targetSquare: targetPosition)
                moves.append(move)
            }
            break
            
            
        }
        return moves
    }
    
    
    
}
