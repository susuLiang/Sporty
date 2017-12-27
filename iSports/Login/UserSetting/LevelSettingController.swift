//
//  LevelSettingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/26.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import Firebase
import KeychainSwift

protocol LevelSettingDelegate: class {
    func levelPreference(_ levelSetting: LevelSettingController, selectedLevel: String)
}

class LevelSettingController: UIViewController {
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    
    weak var delegate: LevelSettingDelegate?
    
    static let shared = LevelSettingController()
    
    var selectedLevel: String? = ""
    
    var keyChain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myBlack
        setUpButtons()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpButtons() {
        buttonA.layer.cornerRadius = 10
        buttonB.layer.cornerRadius = 10
        buttonC.layer.cornerRadius = 10
        buttonD.layer.cornerRadius = 10
    }
    
    @IBAction func selectButtonA(_ sender: Any) {
        buttonA.backgroundColor = myRed
        self.selectedLevel = Level.A.rawValue
        self.delegate?.levelPreference(.shared, selectedLevel: self.selectedLevel!)
    }
    
    @IBAction func selectButtonB(_ sender: Any) {
        buttonB.backgroundColor = myRed
        self.selectedLevel = Level.B.rawValue
        self.delegate?.levelPreference(.shared, selectedLevel: self.selectedLevel!)
    }
    
    @IBAction func selectButtonC(_ sender: Any) {
        buttonC.backgroundColor = myRed
        self.selectedLevel = Level.C.rawValue
        self.delegate?.levelPreference(.shared, selectedLevel: self.selectedLevel!)
    }
    @IBAction func selectButtonD(_ sender: Any) {
        buttonD.backgroundColor = myRed
        self.selectedLevel = Level.D.rawValue
        self.delegate?.levelPreference(.shared, selectedLevel: self.selectedLevel!)
    }
    
    
    @IBAction func saveUserLevel(_ sender: Any) {
        
        let value = self.selectedLevel
        
        if let userUid = keyChain.get("uid") {
            
            let ref = Database.database().reference().child("users").child(userUid)
            
            ref.child("preference").child("level").setValue(value)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let cityAndTimeSettingController = storyboard.instantiateViewController(withIdentifier: "cityAndTimeSettingController") as! CityAndTimeSettingController
            
            cityAndTimeSettingController.controllerType = .city
            
            self.present(cityAndTimeSettingController, animated: true, completion: nil)
        
        }
    }
    
    
}
