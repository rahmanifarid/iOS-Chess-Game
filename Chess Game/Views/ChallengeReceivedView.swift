//
//  ChallengeReceivedView.swift
//  Chess Game
//
//  Created by Farid Rahmani on 7/3/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit

class ChallengeReceivedView: UIView {
    let titleLabel:UILabel = {
        let label = UILabel()
        //label.backgroundColor = UIColor.white
        label.text = "Challenge Received!"
        label.font = UIFont.systemFont(ofSize: 21)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var acceptButton:UIButton = {
        let button = UIButton(type: .system)
        //button.backgroundColor = UIColor.white
        button.setTitle("Accept", for: .normal)
        button.addTarget(self, action: #selector(buttonPessed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 0
        return button
    }()
    lazy var rejectButton:UIButton = {
        let button = UIButton(type: .system)
        //button.backgroundColor = UIColor.white
        button.setTitle("Reject", for: .normal)
        button.addTarget(self, action: #selector(buttonPessed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = 1
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        let horizontalStackView = UIStackView(arrangedSubviews: [acceptButton, rejectButton])
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 20
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.distribution = .fillEqually
        
        let verticalStackView = UIStackView(arrangedSubviews: [titleLabel, horizontalStackView])
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 20
        verticalStackView.distribution = .fillEqually
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(verticalStackView)
        verticalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        verticalStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        verticalStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        verticalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var responseBlock:((_ accepted:Bool, _ challenge:Challenge)->())?
    var challenge:Challenge?
    @objc func buttonPessed(sender:UIButton){
        guard let challenge = self.challenge else {
            print("Challenge is nil")
            return
        }
        switch sender.tag {
        case 0:
            responseBlock?(true, challenge)
        default:
            responseBlock?(false, challenge)
        }
    }
}
