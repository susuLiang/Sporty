//
//  CitySettingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/26.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift

enum SettingType {
    
    case city, time
    
}

protocol CityAndTimeDelegate: class {
    func cityPreference(_ city: CityAndTimeSettingController, selectedCity: String)
    func timePreference(_ city: CityAndTimeSettingController, selectedTime: String)
}

class CityAndTimeSettingController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: CityAndTimeDelegate?
    
    static let shared = CityAndTimeSettingController()
    
    let keyChain = KeychainSwift()
    
    var selected: String? = ""
    
    var controllerType: SettingType = .city
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = myBlack
        tableView.backgroundColor = myBlack
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controllerType {
        case .city:
            return city.count
        case .time:
            return time.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityAndTimeSettingCell
        switch controllerType {
        case .city:
            cell.textLabel?.text = city[indexPath.row]
        case .time:
            cell.textLabel?.text = time[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch controllerType {
        case .city:
            self.selected = city[indexPath.row]
            self.delegate?.cityPreference(.shared, selectedCity: city[indexPath.row])
        case .time:
            self.selected = time[indexPath.row]
            self.delegate?.timePreference(.shared, selectedTime: time[indexPath.row])
        }
    }

    @IBAction func saveUserCity(_ sender: Any) {
        
        switch controllerType {
        case .city:
            
            let value = self.selected
            
            if let userUid = keyChain.get("uid") {
                
                let ref = Database.database().reference().child("users").child(userUid)
                
                ref.child("preference").child("city").setValue(value)
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let cityAndTimeSettingController = storyboard.instantiateViewController(withIdentifier: "cityAndTimeSettingController") as! CityAndTimeSettingController
                
                cityAndTimeSettingController.controllerType = .time
                
                self.present(cityAndTimeSettingController, animated: true, completion: nil)
            }
            break
        case .time:
                let value = self.selected
                
                if let userUid = keyChain.get("uid") {
                    
                    let ref = Database.database().reference().child("users").child(userUid)
                    
                    ref.child("preference").child("time").setValue(value)
                    
                    let tabBarController = TabBarController(itemTypes: [ .map, .home, .my])
                    
                    tabBarController.selectedIndex = 1
                    
                    self.present(tabBarController, animated: true, completion: nil)
                    
                    break
            }
       
        }
    }
}
