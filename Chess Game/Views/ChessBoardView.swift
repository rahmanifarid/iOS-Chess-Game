//
//  ChessBoard.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
protocol ChessViewDataSource {
    func chessBoardView(chessBoardView:ChessBoardView, pieceForPosition:Position) -> Piece?
    
}

protocol ChessViewDelegate {
    func pieceDidMove(sourcePosition:Position, destinationPosition:Position)
    func chessBoardView(chessBoardView:ChessBoardView, validMovePositionsForPieceInPosition position:Position)->[Position]?
    
}

class ChessBoardView:UIView{
    var side:Int
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let mark = UIView()
    var delegate:ChessViewDelegate?
    var dataSource:ChessViewDataSource?
    var playerSide:Piece.PieceColor!
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        reloadData()
    }
    
    func reloadData() {
        var column = 0
        var row = 0
        for _ in 0...63{
            let position = Position(column: column, row: row)
            if let piece = dataSource?.chessBoardView(chessBoardView: self, pieceForPosition: position!){
                putPiece(piece, atPosition: position!)
                
            }
            
            row += 1
            if row > 7{
                column += 1
                row = 0
            }
        }
    }
    
    
    var rotation = CGAffineTransform.identity
    func changeSide(to color:Piece.PieceColor) {
        playerSide = color
        if color == .White{
            rotation = CGAffineTransform.identity
            
        }else{
            rotation = CGAffineTransform(rotationAngle: CGFloat.pi)
            
        }
        
        self.transform = rotation
        for pieceView in piecesOnBoard.values{
            pieceView.transform = rotation
        }
    }
    
    
    
    override init(frame: CGRect) {
        side = Int(frame.height / 8)
        super.init(frame: frame)
        addSubview(label)
        backgroundColor = UIColor.lightGray
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(sender:))))
        mark.alpha = 0
        mark.backgroundColor = UIColor.green
        addSubview(mark)
    }
    @objc func tap(sender:UITapGestureRecognizer) {
        
        let location = sender.location(in: self)
        let x = Int(location.x) / side
        let yi = Int(location.y) / side
        let y = 7 - Int(location.y) / side
        guard let position = Position(column: x, row: y) else {
            return
        }
        if selectedPiecePosition == nil, let _ = piecesOnBoard[position]{
            pieceTapped(atPosition: position)
            return
        }
        if let positions = validPositions, positions.contains(position){
            if let piece = piecesOnBoard[position]{
                piece.removeFromSuperview()
                piecesOnBoard.removeValue(forKey: position)
            }
            let pieceToMove = piecesOnBoard.removeValue(forKey: selectedPiecePosition!)!
            piecesOnBoard[position] = pieceToMove
            delegate?.pieceDidMove(sourcePosition: selectedPiecePosition!, destinationPosition: position)
            UIView.animate(withDuration: 0.2, animations: {
    
                 pieceToMove.frame = CGRect(x: CGFloat(x * self.side), y: CGFloat(yi * self.side), width: CGFloat(self.side), height: CGFloat(self.side))
                
                
            })
            
        }
        selectedPiecePosition = nil
        validPositions = nil
        mark.alpha = 0
        //label.text = "(\(x), \(y))"
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        
        
        var x = 0
        var y = 0
        var i = 0
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(UIColor.white.cgColor)
        
        while i < 32{
            let p = CGPoint(x: x, y: y)
            let path = UIBezierPath(rect: CGRect(origin: p, size: CGSize(width: CGFloat(side), height: CGFloat(side))))
            path.fill()
            x += side * 2
            if x >= side * 8{
                x = 0
                y += side
                if(y / side) % 2 != 0{
                    x = side
                }
            }
            i += 1
            
        }
    }
    var piecesOnBoard = [Position:ChessPieceView]()
    func putPiece(_ piece:Piece, atPosition position:Position) {
        if let piece = piecesOnBoard[position]{
            piece.removeFromSuperview()
            piecesOnBoard.removeValue(forKey: position)
        }
        let frame = CGRect(x: CGFloat(position.column * side), y: CGFloat((7 - position.row) * side), width: CGFloat(side), height: CGFloat(side))
        
        let chessPieceView = ChessPieceView(frame: frame, piece: piece)
        chessPieceView.transform = rotation
        addSubview(chessPieceView)
        piecesOnBoard[position] = chessPieceView
        //chessPieceView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pieceTapped(sender:))))
    }
    
    
    var selectedPiecePosition:Position?
    var validPositions:[Position]?
    
    func pieceTapped(atPosition position:Position){
        
        
        validPositions = delegate?.chessBoardView(chessBoardView: self, validMovePositionsForPieceInPosition: position)
        if validPositions != nil{
            selectedPiecePosition = position
            mark.frame = piecesOnBoard[position]!.frame
            UIView.animate(withDuration: 0.3, animations: {
                self.mark.alpha = 1.0
                })
            print("Valid")
        }
    }
    
    func movePiece(fromPosition source:Position, toPosition target:Position) {
        if let piece = piecesOnBoard[target]{
            piece.removeFromSuperview()
            piecesOnBoard.removeValue(forKey: target)
        }
        guard let pieceToMove = piecesOnBoard.removeValue(forKey: source) else{
            print("No piece in position")
            return
        }
        piecesOnBoard[target] = pieceToMove
        UIView.animate(withDuration: 0.2, animations: {
            
            pieceToMove.frame = CGRect(x: CGFloat(target.column * self.side), y: CGFloat((7 - target.row) * self.side), width: CGFloat(self.side), height: CGFloat(self.side))
            
            
        })
    }
    
    func removePiece(at target:Position) {
        if let piece = piecesOnBoard[target]{
            piece.removeFromSuperview()
            piecesOnBoard.removeValue(forKey: target)
        }
    }
    
    
}
