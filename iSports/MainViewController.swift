//
//  MainViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var level: [Level] = [.A, .B, .C, .D]
    var type: [Sportstype] = [  .basketball,
                                .volleyball,
                                .baseball,
                                .football,
                                .badminton,
                                .tennis,
                                .bowling]
    var city: [String] = ["信義區", "大安區", "松山區", "中正區", "中山區"]
    var time = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
    
    var choosedtype: String?
    var choosedlevel: String?
    var choosedcity: String?
    var choosedtime: String?

    
    
    var searchResults = [Preference]()
    @IBOutlet weak var typeText: UITextField!
    @IBOutlet weak var levelText: UITextField!
    @IBOutlet weak var placeText: UITextField!
    @IBOutlet weak var timeText: UITextField!
    
    var typePicker = UIPickerView()
//    var levelPicker = UIPickerView()
//    var placePicker = UIPickerView()
//    var timePicker = UIPickerView()
//

    @IBOutlet weak var numLabel: UILabel!
   
    @IBAction func search(_ sender: Any) {
        searchResults = [Preference]()
        let ref = Database.database().reference().child("activities").queryOrdered(byChild: "type").queryEqual(toValue: choosedtype)
        ref.observe(.value, with: { (snapshot: DataSnapshot) in
            print(snapshot.value)
            guard let snapShotData = snapshot.value as? [String: AnyObject] else { return }
            for (activitiesId, activitiesData) in snapShotData {
                let id = activitiesId
                guard let type = activitiesData["type"] as? String else { return }
                guard let level = activitiesData["level"] as? String else { return }
                guard let place = activitiesData["place"] as? String else { return }
                guard let time = activitiesData["time"] as? String else { return }
                if time == self.choosedtime && level == self.choosedlevel && place == self.choosedcity{
                    let activities = Preference(id: id, type: Sportstype(rawValue: type)!, level: Level(rawValue: level)!, place: place, time: time)
                self.searchResults.append(activities)
                }
            }
            print(self.searchResults)

        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numLabel.text = String(searchResults.count)
        typeText.inputView = typePicker
        typePicker.delegate = self
        typePicker.dataSource = self
//        timeText.inputView = timePicker
//        levelText.inputView = levelPicker
//        placeText.inputView = placePicker
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 1:
            return type.count
        case 2:
            return level.count
        case 3:
            return time.count
        case 4:
            return city.count
        default:
            return 0
        }

    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 1:
            return type[row].rawValue
        case 2:
            return level[row].rawValue
        case 3:
            return time[row]
        case 4:
            return city[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 1:
            typeText.text = type[row].rawValue
            choosedtype = type[row].rawValue
        case 2:
            levelText.text = level[row].rawValue
            choosedlevel = level[row].rawValue
        case 3:
            timeText.text = time[row]
            choosedtime = time[row]
        case 4:
            placeText.text = city[row]
            choosedcity = city[row]
        default:
            return 
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
