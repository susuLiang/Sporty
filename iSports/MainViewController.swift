//
//  MainViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class MainViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var level: [Level] = [.A, .B, .C, .D]
    var type: [Sportstype] = [.basketball, .volleyball, .baseball, .football, .badminton, .tennis]
    var city: [String] = ["臺北市", "新北市", "基隆市", "桃園市", "新竹市", "新竹縣", "苗栗縣", "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "臺南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣" ]
    var time = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
    var gymType = ["羽球場", "籃球場", "棒球場"]

    @IBOutlet weak var oneText: UITextField!
    @IBOutlet weak var twoText: UITextField!
    @IBOutlet weak var threeText: UITextField!
    @IBOutlet weak var fourText: UITextField!
    
    var typePicker = UIPickerView()
//    var levelPicker = UIPickerView()
//    var placePicker = UIPickerView()
//    var timePicker = UIPickerView()
    var courts: [Court] = []

    @IBOutlet weak var numLabel: UILabel!
   
    @IBAction func search(_ sender: Any) {

        if let city = threeText.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let gym = fourText.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {

            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (Courts, error) in
                if error == nil {
                    print(Courts)
                    self.courts = Courts!
                } else {
                    // todo: error handling
                }
                print(error)
                print(self.courts)
            })
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        numLabel.text = String(searchResults.count)
        oneText.inputView = typePicker
        typePicker.delegate = self
        typePicker.dataSource = self
//        fourText.inputView = timePicker
//        timePicker.delegate = self
//        timePicker.dataSource = self
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
            return gymType.count
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
            return gymType[row]
        case 4:
            return city[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 1:
            oneText.text = type[row].rawValue
        case 2:
            twoText.text = level[row].rawValue
        case 3:
            fourText.text = gymType[row]
        case 4:
            threeText.text = city[row]
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
