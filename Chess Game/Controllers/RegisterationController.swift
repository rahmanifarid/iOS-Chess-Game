//
//  RegisterationController.swift
//  Chess Game
//
//  Created by Farid Rahmani on 6/27/18.
//  Copyright © 2018 Farid Rahmani. All rights reserved.
//

import UIKit
import Firebase
class RegisterationController:UIViewController{
    let nameTextField:UITextField = {
        let textF = UITextField(frame: CGRect(x: 0, y: 200, width: 300, height: 50))
        textF.placeholder = "Your Name"
        return textF
    }()
    let button:UIButton = {
        let button = UIButton(type: UIButtonType.roundedRect)
        button.setTitle("Register", for: .normal)
        button.frame = CGRect(x: 0, y: 270, width: 300, height: 50)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        nameTextField.center.x = view.center.x
        view.addSubview(nameTextField)
        button.center.x = view.center.x
        view.addSubview(button)
        button.addTarget(self, action: #selector(register(_ :)), for: UIControlEvents.touchUpInside)
    }
    
    @objc func register(_ sender:UIButton){
        
        if let username = nameTextField.text {
            let trimmed = username.trimmingCharacters(in: CharacterSet(charactersIn: "\n \t\r"))
            if trimmed.count < 5{
                let alert = "Please enter a name 5 to 20 characters long.".convertToAlertViewController(withTitle: "Invalid Username", actionBlock: {
                    self.dismiss(animated: true, completion: nil)
                    })
                self.present(alert, animated: true, completion: nil)
                return
            }
            let uniqueId = UUID().uuidString
            Firestore.firestore().collection("users").document(uniqueId).setData(["name": username]) { (err) in
                if let error = err{
                    print(error.localizedDescription)
                    let alert = "Something went wrong! please try again.".convertToAlertViewController(withTitle: "Oops!", actionBlock: {
                        self.dismiss(animated: true, completion: nil)
                        })
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                UserDefaults.standard.set(uniqueId, forKey: "userId")
                let usersList = UsersListViewController()
                usersList.userId = uniqueId
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.userId = uniqueId
                self.navigationController?.viewControllers = [usersList]
            }
            
        }
        
    }
}

extension String{
    func convertToAlertViewController(withTitle title:String?, actionBlock:@escaping ()->())->UIAlertController {
        let alert = UIAlertController(title: title, message: self, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            actionBlock()
        }
        alert.addAction(alertAction)
        return alert
    }
}




