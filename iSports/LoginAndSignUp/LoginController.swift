//
//  LoginController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import SCLAlertView

class LoginController: UIViewController {
    
    let keyChain = KeychainSwift()

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBAction func signIn(_ sender: Any) {
        guard let email = emailText.text,
            let password = passwordText.text
            else {
                print("Form is not valid.")
                return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    var message: String = ""
                    
                    switch errCode {
                    case .invalidEmail:
                        message = NSLocalizedString("Invalid email", comment: "")
                        break
                    case .userNotFound:
                        message = NSLocalizedString("Wrong email", comment: "")
                        break
                    case .wrongPassword:
                        message = NSLocalizedString("Wrong password", comment: "")
                        break
                    default:
                        print("Create User Error: \(error!)")
                    }
                    
                    SCLAlertView().showWarning("Error", subTitle: message)
                    
                }
                return
            }
                        
            let tabBarController = TabBarController(itemTypes: [ .map, .home, .my])
            tabBarController.selectedIndex = 1
            self.present(tabBarController, animated: true, completion: nil)
        })
    }
    
    @IBAction func signUp(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpController = storyboard.instantiateViewController(withIdentifier: "signUpController")
        self.present(signUpController, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myWhite
        logInButton.layer.cornerRadius = 10
        logInButton.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
