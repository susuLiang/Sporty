//
//  SignController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/27.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var gifView: UIView!

    @IBOutlet weak var gifImage: UIImageView!
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
        
        
        let thisGif = UIImage.gifImageWithName("sporty")
        self.gifImage.image = thisGif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            self.gifImage.isHidden = true
            self.gifView.isHidden = true
        }
        
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
