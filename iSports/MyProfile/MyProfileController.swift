//
//  MyProfileController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/21.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class MyProfileController: UIViewController {
    @IBOutlet weak var logOutButton: UIButton!
    @IBAction func logOut(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Log out", message: "Be sure to log out?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (action) in
            self.keyChain.clear()
            
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError)
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
            self.present(loginController, animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    let keyChain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myProfile = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-menu"), style: .plain, target: self, action: #selector(showBack))
        navigationItem.leftBarButtonItems = [myProfile]
        userNameLabel.text = keyChain.get("name")
        setLogOutButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func setLogOutButton() {
        logOutButton.layer.cornerRadius = 20
        logOutButton.tintColor = UIColor.black
        logOutButton.titleLabel?.font = UIFont(name: "IowanOldStyle-Bold", size: 22)!
        logOutButton.layer.shadowRadius = 5
    }

}
