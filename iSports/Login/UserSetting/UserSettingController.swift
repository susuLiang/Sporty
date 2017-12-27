//
//  UserSettingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/27.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

class UserSettingController: UIViewController, TypeSettingDelegate, LevelSettingDelegate, CityAndTimeDelegate {

    @IBOutlet weak var cityAndTimeSetting: UIView!
    @IBOutlet weak var levelSetting: UIView!
    @IBOutlet weak var typeSetting: UIView!
    @IBOutlet weak var firstTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var sureButton: UIButton!
    
    var isCity = false
    
    var setting: Preference? = nil
    
    var keyChain = KeychainSwift()
    
    @IBAction func nextSetting(_ sender: Any) {
        if !typeSetting.isHidden {
            levelSetting.isHidden = false
            firstTitle.text = "2 / 4 Level"
            subTitle.text = "Please select your level"
            typeSetting.isHidden = true
        } else if !levelSetting.isHidden {
            firstTitle.text = "3 / 4 City"
            subTitle.text = "Where you live in ?"
            levelSetting.isHidden = true
            CityAndTimeSettingController.shared.controllerType = .city
            isCity = true
        } else if isCity {
            firstTitle.text = "4 / 4 Time"
            subTitle.text = "When are you available ?"
            CityAndTimeSettingController.shared.controllerType = .time
            isCity = false
        } else {
            
            print(self.setting)
            
            let value = ["type": setting?.type, "level": setting?.level?.rawValue, "city": setting?.city, "time": setting?.time]
      
                if let userUid = keyChain.get("uid") {
                    
                    let ref = Database.database().reference().child("users").child(userUid)
                    
                    ref.child("preference").setValue(value)
                    
                    let tabBarController = TabBarController(itemTypes: [ .map, .home, .my])
                    
                    tabBarController.selectedIndex = 1
                    
                    self.present(tabBarController, animated: true, completion: nil)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        TypeSettingController.shared.delegate = self
        LevelSettingController.shared.delegate = self
        CityAndTimeSettingController.shared.delegate = self
        
        sureButton.layer.cornerRadius = 10
        
        typeSetting.isHidden = false
        cityAndTimeSetting.isHidden = true
        levelSetting.isHidden = false
        
        firstTitle.text = "1 / 4 Type"
        subTitle.text = "What kind of sports you like ?"
        
        view.backgroundColor = myBlack
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func cityPreference(_ city: CityAndTimeSettingController, selectedCity: String) {
        self.setting?.city = selectedCity
    }
    
    func timePreference(_ city: CityAndTimeSettingController, selectedTime: String) {
        self.setting?.time = selectedTime
    }
    
    func levelPreference(_ levelSetting: LevelSettingController, selectedLevel: String) {
        self.setting?.level = Level(rawValue: selectedLevel)
    }
    
    func preferenceType(_ typeSetting: TypeSettingController, type: String) {
        self.setting?.type = type
    }
    
}
