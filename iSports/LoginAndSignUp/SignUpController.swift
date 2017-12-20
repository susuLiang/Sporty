//
//  SignUpController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/19.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {

    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUp(_ sender: Any) {

        guard let email = emailText.text,
            let password = passwordText.text,
            let name = nameText.text
            else {
                print("Form is not valid")
                return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            
            if error != nil {
                print(error)
                return
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
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let userSettingController = storyboard.instantiateViewController(withIdentifier: "userSettingController") as! UserSettingController
                userSettingController.userUid = uid
                self.present(userSettingController, animated: true, completion: nil)
            })
        })
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
