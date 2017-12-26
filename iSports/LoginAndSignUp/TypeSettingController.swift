//
//  UserSettingTypeController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/26.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class TypeSettingController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedType: String = ""
    
    let keyChain = KeychainSwift()
    
    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sureButton.layer.cornerRadius = 10
        view.backgroundColor = myBlack
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeCell", for: indexPath) as! TypeSettingCell
        let type = typeArray[indexPath.row]
        cell.typeLabel.text = type
        var iconName: String = ""
        switch type {
        case "羽球": iconName = "settingBadminton"
        case "棒球": iconName = "settingBaseball"
        case "籃球": iconName = "settingBasketball"
        case "排球": iconName = "settingVolleyball"
        case "網球": iconName = "settingTennis"
        case "足球": iconName = "settingFootball"
        default: ""
        }
        DispatchQueue.main.async {
            cell.typeImage.image = UIImage(named: iconName)

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedType = typeArray[indexPath.row]
        self.selectedIndexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }

    @IBAction func saveUserLikedType(_ sender: Any) {
        
        let value = ["type": self.selectedType]
        
        if let userUid = keyChain.get("uid") {
            
            let ref = Database.database().reference().child("users").child(userUid)
            
            ref.child("preference").setValue(value)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let levelSettingController = storyboard.instantiateViewController(withIdentifier: "levelSettingController") as! LevelSettingController
            
            self.present(levelSettingController, animated: true, completion: nil)
        }
    }
}
