//
//  searchViewController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/15.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class SearchViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var sureButton: UIButton!

    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var levelTF: UITextField!
    @IBOutlet weak var timeTF: UITextField!
    @IBOutlet weak var placeTF: UITextField!

    @IBAction func backButton(_ sender: Any) {
        self.view.removeFromSuperview()
    }

    @IBAction func sureButton(_ sender: Any) {
        if typeTF.text == "" {
            SCLAlertView().showWarning(NSLocalizedString("Warning", comment: ""), subTitle: NSLocalizedString("Should enter sports type", comment: ""))
            return
        }
        guard let type = typeTF.text,
            let level = levelTF.text,
            let city = placeTF.text,
            let time = timeTF.text else {
            return
        }
        mainViewController?.selectedPreference = Preference(type: type, level: level, place: city, time: time)
        self.view.removeFromSuperview()
    }

    var mainViewController: ListsController?

    var selectedType: String?
    var selectedLevel: String?
    var selectedPlace: String?
    var selectedTime: String?

    var typePicker = UIPickerView()
    var levelPicker = UIPickerView()
    var timePicker = UIPickerView()
    var placePicker = UIPickerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerDelegate()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        view.frame = CGRect(x: 0, y: 0, width: 150, height: UIScreen.main.bounds.height)

        sureButton.layer.cornerRadius = 10

        typeTF.inputView = typePicker
        levelTF.inputView = levelPicker
        timeTF.inputView = timePicker
        placeTF.inputView = placePicker

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        switch pickerView {
        case typePicker: return typeArray.count
        case levelPicker : return levelArray.count
        case timePicker: return time.count
        case placePicker: return cityArray.count
        default: return 1

        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case typePicker: return typeArray[row]
        case levelPicker : return levelArray[row]
        case timePicker: return time[row]
        case placePicker: return cityArray[row]
        default: return ""
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case typePicker:
            typeTF.text = typeArray[row]
            self.selectedType = typeArray[row]
        case levelPicker :
            levelTF.text = levelArray[row]
            self.selectedLevel = levelArray[row]
        case timePicker:
            timeTF.text = time[row]
            self.selectedTime = time[row]
        case placePicker:
            placeTF.text = cityArray[row]
            self.selectedPlace = cityArray[row]
        default: break
        }
    }

    typealias ShowAlertDismissHandler = () -> Void

    func showAlert(title: String?, message: String?, dismiss handler: ShowAlertDismissHandler?) {

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        let ok = UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .cancel,
            handler: { _ in handler?() }
        )

        alert.addAction(ok)

        present(alert, animated: true, completion: nil)

    }
}

extension SearchViewController {

    func pickerDelegate() {
        typePicker.delegate = self
        typePicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        placePicker.delegate = self
        placePicker.dataSource = self
        timePicker.delegate = self
        timePicker.dataSource = self
    }
}
