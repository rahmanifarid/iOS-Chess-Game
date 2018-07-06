//
//  UsersListViewController.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/27/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class UsersListViewController: UIViewController {
    let tableView = UITableView(frame: CGRect.zero)
    var users = [User]()
    var userId:String!
    var challenges = [Challenge]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.register(UsersListTableCell.self, forCellReuseIdentifier: "CellId")
        tableView.dataSource = self
        view.addSubview(tableView)
        let footer = UIView()
        tableView.tableFooterView = footer
        downloadUsers()
        listenToChallenges()
        listenToResponses()
        // Do any additional setup after loading the view.
    }
    
    func downloadUsers() {
        Firestore.firestore().collection("users").addSnapshotListener { (qs, err) in
            if let error = err{
                print(error.localizedDescription)
                
            }
            
            if let snapshot = qs {
                var users = [User]()
                for document in snapshot.documents{
                    let data = document.data()
                    let user = User.createWith(data: data)
                    user.id = document.documentID
                    if user.id! == self.userId{
                        continue
                    }
                    users.append(user)
                    
                }
                self.users = users
                self.tableView.reloadData()
            }
        }
    }
    
    func listenToChallenges() {
        Firestore.firestore().collection("challenges").document(userId).collection("pending").order(by: "date", descending:true).addSnapshotListener { (qs, err) in
            if let snapshot = qs{
                var receivedChallenges = [Challenge]()
                for document in snapshot.documents{
                    let data = document.data()
                    var receivedChallenge = Challenge.createWith(data: data)
//                    if !self.challenges.contains(where: { (challenge) -> Bool in
//                        challenge.id == receivedChallenge.id
//                    }){
//                        self.challenges.append(receivedChallenge)
//                    }
                    receivedChallenge.id = document.documentID
                    receivedChallenges.append(receivedChallenge)
                    
                    
                }
                self.challenges = receivedChallenges
                self.challengesReceived()
            }
        }
    }
    
    func listenToResponses() {
       
        Firestore.firestore().collection("challenges").document(userId).collection("responses").order(by: "date", descending:true).addSnapshotListener { (ss, err) in
            print("response received")
            if let snapshot = ss{
                if let doc = snapshot.documents.first{
                    let response = Challenge.createWith(data: doc.data())
                    if let responseDate = response.date, Date().timeIntervalSince(responseDate) < 6000{
                        let chessViewController = ChessViewController()
                        chessViewController.setupWith(challenge: response)
                        self.present(chessViewController, animated: true, completion: nil)
                    }
                    
                    Firestore.firestore().collection("challenges").document(self.userId).collection("responses").document(doc.documentID).delete()
                    //lkjlkj
                    
                }
            }
        }
    }
    var challengeViewDisplayed = false
    func challengesReceived() {
        if challengeViewDisplayed || challenges.count < 1{
            return
        }
        challengeViewDisplayed = true
        let challenge = challenges.removeFirst()
        let challengeView = ChallengeReceivedView(frame: self.view.bounds)
        challengeView.challenge = challenge
        challengeView.responseBlock = {(accepted, challenge) in
            if accepted{
                print("Challenge accepted")
                challenge.respond(accepted:true)
                let chessVC = ChessViewController()
                chessVC.setupWith(challenge: challenge)
                self.present(chessVC, animated: true, completion: nil)
                for challenge in self.challenges{
                    challenge.respond(accepted:false)
                }
                self.challenges.removeAll()
                
            }else{
                challenge.respond(accepted: false)
                print("Challenge rejected")
            }
            
            challengeView.removeFromSuperview()
            self.challengeViewDisplayed = false
            self.challengesReceived() //Call this in case there are more received challenges pending
        }
        
        view.addSubview(challengeView)
        print("challenge view displayed")
    }
    
    func challenge(userId:String) {
        print("Send challenge to user with id: \(userId)")
        let gameId = UUID().uuidString
        
        let playerPlayingWhite:String = arc4random_uniform(1) == 0 ? self.userId : userId
        Firestore.firestore().collection("challenges").document(userId).collection("pending").addDocument(data: ["gameId":gameId, "senderId": self.userId, "date":Date(), "playerPlayingWhite": playerPlayingWhite, "seen": false])
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UsersListViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellId", for: indexPath) as! UsersListTableCell
        cell.setup(withUser:users[indexPath.row])
        cell.challengeButtonAction = challenge
        return cell
    }
}
