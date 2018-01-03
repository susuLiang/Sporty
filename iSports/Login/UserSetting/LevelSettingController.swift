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

class LevelSettingController: UIViewController {
    
    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    
    var selectedLevel: String? = ""
    
    var keyChain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sureButton.layer.cornerRadius = 10
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
        buttonA.backgroundColor = mySkyBlue
        self.selectedLevel = Level.A.rawValue
    }
    
    @IBAction func selectButtonB(_ sender: Any) {
        buttonB.backgroundColor = mySkyBlue
        self.selectedLevel = Level.B.rawValue
    }
    
    @IBAction func selectButtonC(_ sender: Any) {
        buttonC.backgroundColor = mySkyBlue
        self.selectedLevel = Level.C.rawValue
    }
    @IBAction func selectButtonD(_ sender: Any) {
        buttonD.backgroundColor = mySkyBlue
        self.selectedLevel = Level.D.rawValue
    }
    
    
    @IBAction func saveUserLevel(_ sender: Any) {
        
        let value = self.selectedLevel
        
        if let userUid = keyChain.get("uid") {
            
            let ref = Database.database().reference().child("users").child(userUid)
            
            ref.child("preference").child("level").setValue(value)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let cityAndTimeSettingController = storyboard.instantiateViewController(withIdentifier: "cityAndTimeSettingController") as? CityAndTimeSettingController {
            
                cityAndTimeSettingController.controllerType = .city
                
                self.present(cityAndTimeSettingController, animated: true, completion: nil)
            }
        }
    }
}
