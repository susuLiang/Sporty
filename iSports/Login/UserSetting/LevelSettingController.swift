//
//  LevelSettingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/26.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import Firebase

class LevelSettingController: UIViewController {

    @IBOutlet weak var sureButton: UIButton!
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!

    var selectedLevel: String? = ""

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
        self.selectedLevel = "A"
        buttonB.backgroundColor = .clear
        buttonC.backgroundColor = .clear
        buttonD.backgroundColor = .clear
    }

    @IBAction func selectButtonB(_ sender: Any) {
        buttonB.backgroundColor = mySkyBlue
        self.selectedLevel = "B"
        buttonA.backgroundColor = .clear
        buttonC.backgroundColor = .clear
        buttonD.backgroundColor = .clear
    }

    @IBAction func selectButtonC(_ sender: Any) {
        buttonC.backgroundColor = mySkyBlue
        self.selectedLevel = "C"
        buttonB.backgroundColor = .clear
        buttonA.backgroundColor = .clear
        buttonD.backgroundColor = .clear
    }
    @IBAction func selectButtonD(_ sender: Any) {
        buttonD.backgroundColor = mySkyBlue
        self.selectedLevel = "D"
        buttonB.backgroundColor = .clear
        buttonC.backgroundColor = .clear
        buttonA.backgroundColor = .clear
    }

    @IBAction func saveUserLevel(_ sender: Any) {

        let value = self.selectedLevel

        if let userUid = UserDefaults.standard.string(forKey: UserDefaultKey.uid.rawValue) {

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
