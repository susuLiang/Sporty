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

    @IBOutlet weak var userNameLabel: UILabel!
    
    let keyChain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myProfile = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(showBack))
        navigationItem.leftBarButtonItems = [myProfile]
        userNameLabel.text = keyChain.get("name")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func showBack() {
        navigationController?.popViewController(animated: true)
    }

}
