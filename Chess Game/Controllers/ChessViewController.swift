//
//  ViewController.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/26/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class ChessViewController: UIViewController {
    let chessBoard = ChessBoard()
    var chessBoardView:ChessBoardView!
    var moves = [MoveStruct]()
    var userSide:Piece.PieceColor!
    var challenge:Challenge!
    var moveForLastTappedPiece:[Position:Move]?
    var previousPositions = [String:Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("now loaded")
        //l;kl;
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupWith(challenge:Challenge) {
        self.challenge = challenge
        let frame = CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        chessBoardView = ChessBoardView(frame: frame)
        chessBoardView.dataSource = self
        chessBoardView.delegate = self
        view.addSubview(chessBoardView)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let userId = appDelegate.userId!
        if challenge.playerPlayingWhite! == userId{
            userSide = .White
        }else{
            userSide = .Black
            chessBoardView.changeSide(to: .Black)
        }
        
        let moveCollectionToListenTo = userSide == .White ? "black" : "white"
        
        Firestore.firestore().collection("games").document(challenge.gameId!).collection(moveCollectionToListenTo).addSnapshotListener { (ss, err) in
            if let error = err{
                let alert = error.localizedDescription.convertToAlertViewController(withTitle: "Something went wrong", actionBlock: {
                    self.dismiss(animated: true, completion: nil)
                    })
                self.present(alert, animated: true, completion: nil)
            }
            if let snapshot = ss{
                for document in snapshot.documents{
                    let move = MoveStruct.createWith(data: document.data())
                    if !self.moves.contains(move){
                        self.moves.append(move)
                        self.performReceivedMove()
                    }
                }
            }
        }
    }
    
    func performReceivedMove() {
        if let moveStruct = moves.last{
            var move:Move
            let moveType = moveStruct.moveType
            let color:Piece.PieceColor = userSide == .White ? .Black : .White
            if moveType == "castleKingside" || moveType == "castleQueenside" {
                
                let castleType:Castle.CastleType = moveType == "castleKingside" ? .KingSide : .QueenSide
                move = Castle(withBoard: chessBoard, side: color, castleType: castleType)
                performCastleOnChessView(type: castleType, side: color)
                
            }else if moveType == "pawnMove"{
                move = PawnMove(withBoard: chessBoard, sourceSquare: moveStruct.sourcePosition, targetSquare: moveStruct.targetPosition)
                chessBoardView.movePiece(fromPosition: move.sourceSquare, toPosition: move.targetSquare)
            }else if moveType == "enPassantCapture"{
                move = EnPassantCapture(withBoard: chessBoard, sourceSquare: moveStruct.sourcePosition, targetSquare: moveStruct.targetPosition)
                chessBoardView.movePiece(fromPosition: move.sourceSquare, toPosition: move.targetSquare)
                chessBoardView.removePiece(at:(move as! EnPassantCapture).enPassantSquare)
            }else if moveType == "promotion"{
                let opponnetColor:Piece.PieceColor = userSide == .White ? .Black : .White
                var promotionPiece:Piece
                switch moveStruct.promotionTo{
                case "queen":
                   promotionPiece = Queen(withColor: opponnetColor, position: moveStruct.targetPosition)
                case "rook":
                    promotionPiece = Rook(withColor: opponnetColor, position: moveStruct.targetPosition)
                case "bishop":
                    promotionPiece = Bishop(withColor: opponnetColor, position: moveStruct.targetPosition)
                    
                default:
                    promotionPiece = Knight(withColor: opponnetColor, position: moveStruct.targetPosition)
                }
                move = Promotion(withBoard: chessBoard, sourceSquare: moveStruct.sourcePosition, targetSquare: moveStruct.targetPosition, promotionPiece: promotionPiece)
                self.promotePawnOnBoardView(at: moveStruct.sourcePosition, to: promotionPiece)
            }else{
                move = Move(withBoard: chessBoard, sourceSquare: moveStruct.sourcePosition, targetSquare: moveStruct.targetPosition)
                chessBoardView.movePiece(fromPosition: move.sourceSquare, toPosition: move.targetSquare)
            }
            move.execute()
            checkForThreefoldRepeatation()
        }
    }
    
    func checkForThreefoldRepeatation() {
        let boardPresentation = chessBoard.boardPresentation()
        if var repeatations = previousPositions[boardPresentation]{
            repeatations += 1
            if repeatations > 2{
                print("Threefold repeatations")
            }else{
                previousPositions[boardPresentation] = repeatations
            }
        }else{
            previousPositions[boardPresentation] = 1
        }
    }
    
    func performCastleOnChessView(type:Castle.CastleType, side:Piece.PieceColor) {
        let kingRow = side == .White ? 0 : 7
        if side != userSide{
            
            let kingTargetColumn = type == .KingSide ? 6 : 2
            let kingPosition = Position(column: 4, row: kingRow)!
            let kingTargetPosition = Position(column: kingTargetColumn, row: kingRow)!
            chessBoardView.movePiece(fromPosition: kingPosition, toPosition: kingTargetPosition)
        }
        let (rookSourceColumn, rookTargetColumn) = type == .KingSide ? (7, 5) : (0, 3)
        let rookPosition = Position(column: rookSourceColumn, row: kingRow)!
        let rookTargetPosition = Position(column: rookTargetColumn, row: kingRow)!
        chessBoardView.movePiece(fromPosition: rookPosition, toPosition: rookTargetPosition)
    }
    
    func promotePawnOnBoardView(at square:Position, to piece:Piece) {
        chessBoardView.removePiece(at: square)
        chessBoardView.putPiece(piece, atPosition: piece.position)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ChessViewController:ChessViewDataSource, ChessViewDelegate{
    func chessBoardView(chessBoardView: ChessBoardView, validMovePositionsForPieceInPosition position: Position) -> [Position]? {
        
        moveForLastTappedPiece = nil
        let piece = chessBoard.piece(inPosition: position)
        if piece.color != userSide{
            return nil
        }
        
        if let validMoves = piece.validMoves(onBoard: chessBoard){
            moveForLastTappedPiece = [Position:Move]()
            for move in validMoves{
                moveForLastTappedPiece?[move.targetSquare] = move
            }
        }
        return moveForLastTappedPiece != nil ? Array(moveForLastTappedPiece!.keys) : nil
    }
    
    func chessBoardView(chessBoardView: ChessBoardView, pieceForPosition: Position) -> Piece? {
        let piece = chessBoard.allPieces[pieceForPosition.row][pieceForPosition.column]
        if type(of: piece) != NullPiece.self{
            return piece
        }
        
        return nil
    }
    
    
    
    func pieceDidMove(sourcePosition: Position, destinationPosition: Position) {
        var move = moveForLastTappedPiece![destinationPosition]!
        
        var moveType:String = "regular"
        if let castle = move as? Castle{
            moveType = castle.type == .KingSide ? "castleKingside" : "castleQueenside"
            performCastleOnChessView(type: castle.type, side: userSide)
            
            
        }else if type(of: move) == PawnMove.self{
            let queeningRow = userSide == .White ? 7 : 0
            if move.targetSquare.row == queeningRow{
                moveType = "promotion"
            }else{
               moveType = "pawnMove"
            }
            
        }else if let enPassantCapture = move as? EnPassantCapture{
            moveType = "enPassantCapture"
            chessBoardView.removePiece(at: enPassantCapture.enPassantSquare)
        }
        var moveToSend = ["sourceColumn":move.sourceSquare.column, "sourceRow":move.sourceSquare.row, "targetColumn":move.targetSquare.column, "targetRow":move.targetSquare.row, "date":Date(), "seen":false, "moveType":moveType] as [String : Any]
        let collectionName = userSide == .White ? "white" : "black"
        if moveType == "promotion"{
            let actionSheet = UIAlertController(title: nil, message: "Promote the pawn to:", preferredStyle: .actionSheet)
            
            let actionBlock = {(action:UIAlertAction) in
                var promotionPiece:Piece
                switch action.title {
                case "Queen":
                    print("promote to queen")
                    promotionPiece = Queen(withColor: self.userSide, position: move.targetSquare)
                    moveToSend["promotionTo"] = "queen"
                case "Rook":
                    print("promote to rook")
                    promotionPiece = Rook(withColor: self.userSide, position: move.targetSquare)
                    moveToSend["promotionTo"] = "rook"
                case "Bishop":
                    promotionPiece = Bishop(withColor: self.userSide, position: move.targetSquare)
                    moveToSend["promotionTo"] = "bishop"
                    print("Promote to Bishop")
                case "Knight":
                    promotionPiece = Knight(withColor: self.userSide, position: move.targetSquare)
                    moveToSend["promotionTo"] = "knight"
                    print("Promote to Knight")
                default:
                    promotionPiece = Piece(withColor: self.userSide, position: move.targetSquare)
                    print("Unrecognised Promotion")
                }
                move = Promotion(withBoard: self.chessBoard, sourceSquare: move.sourceSquare, targetSquare: move.targetSquare, promotionPiece: promotionPiece)
                move.execute()
                self.checkForThreefoldRepeatation()
                self.promotePawnOnBoardView(at: move.sourceSquare, to: promotionPiece)
                Firestore.firestore().collection("games").document(self.challenge.gameId!).collection(collectionName).addDocument(data: moveToSend)
            }
            let actionQueen = UIAlertAction(title: "Queen", style: .default, handler: actionBlock)
            let actionRook = UIAlertAction(title: "Rook", style: .default, handler:actionBlock)
            let actionBishop = UIAlertAction(title: "Bishop", style: .default, handler: actionBlock)
            let actionKnight = UIAlertAction(title: "Knight", style: .default, handler: actionBlock)
            actionSheet.addAction(actionQueen)
            actionSheet.addAction(actionRook)
            actionSheet.addAction(actionBishop)
            actionSheet.addAction(actionKnight)
            self.present(actionSheet, animated: true, completion: nil)
        }else{
            move.execute()
           self.checkForThreefoldRepeatation()
            Firestore.firestore().collection("games").document(challenge.gameId!).collection(collectionName).addDocument(data: moveToSend)
        }
        //moves.append(move)
    }
    
    
}

