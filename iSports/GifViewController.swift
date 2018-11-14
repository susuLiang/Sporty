//
//  GifViewController.swift
//  iSports
//
//  Created by Susu Liang on 2018/1/6.
//  Copyright © 2018年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import SwiftyGif

class GifViewController: UIViewController {

    @IBOutlet weak var gifImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let gifmanager = SwiftyGifManager(memoryLimit: 20)
        let gif = UIImage(gifName: "sporty", levelOfIntegrity: 1)
        self.gifImage.setGifImage(gif, manager: gifmanager, loopCount: 1)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {

            if Auth.auth().currentUser?.uid == nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
                self.present(loginController, animated: false, completion: nil)
            } else {
                let tabBarController = TabBarController(itemTypes: [.home, .map, .my, .setting])
                tabBarController.selectedIndex = 0
                self.present(tabBarController, animated: false, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
