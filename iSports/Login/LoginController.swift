//
//  SignController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/27.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBAction func signInOrUp(_ sender: Any) {
        if !goSignUp {
            signInPage.isHidden = false
            signUpPage.isHidden = true
            signButton.setTitle("Sign up now", for: .normal)
            goSignUp = true
        } else {
            signInPage.isHidden = true
            signUpPage.isHidden = false
            signButton.setTitle("Back to sign in", for: .normal)
            goSignUp = false
        }
    }
    @IBOutlet weak var signUpPage: UIView!
    @IBOutlet weak var signInPage: UIView!
    @IBOutlet weak var signButton: UIButton!
    var goSignUp = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myWhite
        signInPage.isHidden = false
        signUpPage.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
