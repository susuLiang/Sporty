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
import TKSubmitTransition

class SignInController: UIViewController {
    
    let keyChain = KeychainSwift()
    
    @IBOutlet weak var logInButton: TKTransitionSubmitButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBAction func signIn(_ sender: Any) {
        logInButton.startLoadingAnimation()
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
                    self.logInButton.startFinishAnimation(0.2, completion: nil)
                    SCLAlertView().showWarning("Error", subTitle: message)
                    
                }
                return
            }
                        
            let uid = Auth.auth().currentUser?.uid

            self.keyChain.set(uid!, forKey: "uid")
            self.keyChain.set(email, forKey: "email")
            self.logInButton.startFinishAnimation(0.2, completion: {
                let tabBarController = TabBarController(itemTypes: [ .map, .home, .my])
                tabBarController.selectedIndex = 1
                self.present(tabBarController, animated: true, completion: nil)
                })
            
        })
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.layer.cornerRadius = 10
        logInButton.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
