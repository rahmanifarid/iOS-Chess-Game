//
//  UsersListTableCell.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/27/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class UsersListTableCell: UITableViewCell {
    var challengeButtonAction:((String)->())?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    let userName:UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 20, width: 200, height: 50)
        return label
    }()
    lazy var challengeButton:UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.frame = CGRect(x: 240, y: 20, width: 100, height: 50)
        button.setTitle("Challenge", for: .normal)
        button.addTarget(self, action: #selector(challengeButtonPress(sender:)), for: .touchUpInside)
        return button
    }()
    
    @objc func challengeButtonPress(sender:UIButton) {
        guard let user = self.user else{
            return
        }
        challengeButtonAction?(user.id!)
        
    }
    
    private func setupUI() {
        userName.center.y = self.center.y
        challengeButton.center.y = self.center.y
        
        addSubview(userName)
        addSubview(challengeButton)
    }
    var user:User?
    
    func setup(withUser user:User) {
        userName.text = user.name
        self.user = user
    }
    
    

}
