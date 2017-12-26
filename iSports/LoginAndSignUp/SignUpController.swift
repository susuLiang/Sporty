//
//  SignUpController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/19.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import SCLAlertView

class SignUpController: UIViewController {
    
    let keyChain = KeychainSwift()

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        guard let email = emailText.text,
            let password = passwordText.text else {
            return
        }
        
        guard let name = nameText.text, !name.isEmpty else {
            SCLAlertView().showWarning("Error", subTitle: "Must enter name")

//            showAlert(title: "Error", message: "Must enter name", dismiss: nil)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            
            if error != nil {
                if let errCode = AuthErrorCode(rawValue: error!._code) {

                    var message: String = ""
                    
                    switch errCode {
                    case .invalidEmail:
                        message = NSLocalizedString("Invalid email", comment: "")
                    case .emailAlreadyInUse:
                        message = NSLocalizedString("Email already in use", comment: "")
                    case .weakPassword:
                        message = NSLocalizedString("Password should be greater than six digits", comment: "")
                    case .missingEmail:
                        message = NSLocalizedString("Must enter email", comment: "")
                   
                    default:
                        print("Create User Error: \(error!)")
                        
                    }
                    
                    SCLAlertView().showWarning("Error", subTitle: message)

//                    self.showAlert(title: "Error", message: message, dismiss: nil)
                    
                    return
                }
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let ref = Database.database().reference()
            let userReference = ref.child("users").child(uid)
            let value = ["name": name, "email": email]
            userReference.updateChildValues(value, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err)
                    return
                }

                self.keyChain.set(email, forKey: "email")
                self.keyChain.set(password, forKey: "password")
                self.keyChain.set(name, forKey: "name")
                self.keyChain.set(uid, forKey: "uid")
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let userSettingController = storyboard.instantiateViewController(withIdentifier: "typeSettingController") as! TypeSettingController
                self.present(userSettingController, animated: true, completion: nil)
            })
        })
    }
   
    override func viewDidLoad() {
        keyChain.clear()
        super.viewDidLoad()
        view.backgroundColor = myWhite
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    typealias ShowAlertDismissHandler = () -> Void
    
    func showAlert(title: String?, message: String?, dismiss handler: ShowAlertDismissHandler?) {
        
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let ok = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .cancel,
            handler: { _ in handler?() }
        )
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
        
    }
}
