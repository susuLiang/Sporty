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
import TKSubmitTransition

class SignUpController: UIViewController {

    @IBOutlet weak var signUpButton: TKTransitionSubmitButton!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!

    @IBAction func signUp(_ sender: Any) {
        signUpButton.startLoadingAnimation()
        guard let email = emailText.text,
            let password = passwordText.text else {
            return
        }

        guard let name = nameText.text, !name.isEmpty else {
            SCLAlertView().showWarning("Error", subTitle: NSLocalizedString("Must enter name", comment: ""))
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
                    self.signUpButton.startFinishAnimation(0.2, completion: nil)
                    SCLAlertView().showWarning("Error", subTitle: message)
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
                
                guard err == nil else {
                    print(err)
                    return
                }
                
                KeychainSwift().set(password, forKey: "password")
                UserDefaults.standard.set(uid, forKey: UserDefaultKey.uid.rawValue)
                UserDefaults.standard.set(email, forKey: UserDefaultKey.email.rawValue)
                UserDefaults.standard.set(name, forKey: UserDefaultKey.name.rawValue)
                UserDefaults.standard.synchronize()
                
                self.signUpButton.startFinishAnimation(0.2, completion: {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let userSettingController = storyboard.instantiateViewController(withIdentifier: "typeSettingController") as? TypeSettingController else {
                        print("TypeSettingController invalid")
                        return
                    }
                    self.present(userSettingController, animated: true, completion: nil)
                })
            })
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 10
        signUpButton.layer.shadowRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    typealias ShowAlertDismissHandler = () -> Void

    func showAlert(title: String?, message: String?, dismiss handler: ShowAlertDismissHandler?) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let ok = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                               style: .cancel,
                               handler: { _ in handler?() })

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)

    }
}
