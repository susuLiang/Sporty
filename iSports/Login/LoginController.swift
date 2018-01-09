//
//  SignController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/27.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class LoginController: UIViewController {

    @IBAction func send(_ sender: Any) {
//        let alert = SCLAlertView()
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)

        let txt = alert.addTextField(NSLocalizedString("Email", comment: ""))

        alert.addButton(NSLocalizedString("Done", comment: "")) {
            if let email = txt.text {
                Auth.auth().sendPasswordReset(withEmail: email) { error in
                    if error != nil {
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            var message: String = ""

                            switch errCode {
                            case .userNotFound:
                                message = NSLocalizedString("User not found", comment: "")
                            case .missingEmail:
                                message = NSLocalizedString("Please enter your email", comment: "")
                            case .invalidEmail:
                                message = NSLocalizedString("The Email address is badly formatted", comment: "")

                            default:
                                print("Email User Error: \(error!)")
                            }
                            SCLAlertView().showWarning("Error", subTitle: message)
                        }
                    }
                    SCLAlertView().showSuccess(NSLocalizedString("Email sent", comment: ""), subTitle: NSLocalizedString("Please check your mail to reset password", comment: ""))
                }
            }
        }
        alert.addButton(NSLocalizedString("Cancel", comment: ""), action: {})
        alert.showEdit(NSLocalizedString("Enter your email", comment: ""), subTitle: "")
    }
    @IBOutlet weak var loginIcon: UIImageView!
    @IBOutlet weak var logInLabel: UILabel!
    @IBAction func signInOrUp(_ sender: Any) {
        if !goSignUp {
            signInPage.isHidden = false
            signUpPage.isHidden = true
            logInLabel.text = NSLocalizedString("Sign In", comment: "")
            signButton.setTitle(NSLocalizedString("Sign up now", comment: ""), for: .normal)
            goSignUp = true
        } else {
            signInPage.isHidden = true
            signUpPage.isHidden = false
            logInLabel.text = NSLocalizedString("Sign Up", comment: "")
            signButton.setTitle(NSLocalizedString("Back to sign in", comment: ""), for: .normal)
            goSignUp = false
        }
    }
    @IBOutlet weak var signUpPage: UIView!
    @IBOutlet weak var signInPage: UIView!
    @IBOutlet weak var signButton: UIButton!
    var goSignUp = true

    override func viewDidLoad() {
        super.viewDidLoad()

        logInLabel.text = NSLocalizedString("Sign In", comment: "")
        signInPage.isHidden = false
        signUpPage.isHidden = true

        loginIcon.layer.cornerRadius = 10
        loginIcon.clipsToBounds = true
        loginIcon.layer.shadowRadius = 5
        loginIcon.layer.shadowOffset = CGSize(width: 1, height: 3)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
