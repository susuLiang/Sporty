//
//  ActivityController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import NVActivityIndicatorView

class ActivityController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var mapPlacedView: UIView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var addNameTextField: UITextField!
    @IBOutlet weak var addCityTextField: UITextField!
    @IBOutlet weak var addLevelTextField: UITextField!
    @IBOutlet weak var addTimeTextField: UITextField!
    @IBOutlet weak var addPlaceTextField: UITextField!
    @IBOutlet weak var addNumberTextField: UITextField!
    @IBOutlet weak var addFeeTextField: UITextField!
    @IBOutlet weak var addAuthorTextField: UITextField!
    @IBOutlet weak var addTypeTextField: UITextField!
    
    var selectedActivity: Activity?  {
        
        didSet {
            navigationItem.rightBarButtonItem = nil
            addNameTextField.text = selectedActivity?.id
            addAuthorTextField.text = selectedActivity?.author
            addTypeTextField.text = selectedActivity?.type.rawValue
            addLevelTextField.text = selectedActivity?.level.rawValue
            addTimeTextField.text = selectedActivity?.time
            addPlaceTextField.text = selectedActivity?.place.placeName
            if let number = selectedActivity?.number,
                let allNumber = selectedActivity?.allNumber,
                let fee = selectedActivity?.fee
            {
                addNameTextField.text = "\(number) / \(allNumber)"
                addFeeTextField.text = "\(fee)"
            }
        }
    }
    
    let loadingIndicator = LoadingIndicator()

    override func viewDidLoad() {
        super.viewDidLoad()
//        if (addTypeTextField.text?.isEmpty)! && (addCityTextField.text?.isEmpty)! {
//            let alert = UIAlertController(title: "No text", message: "Please Enter Text In The Box", preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alert.addAction(defaultAction)
//        }
        setLabels()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func save() {
        guard
            let level = addLevelTextField.text,
            let num = addNumberTextField.text,
            let fee = addFeeTextField.text
            else {
                print("Form is not valid")
                return
            }
        let ref = Database.database().reference()
        let value = ["name": "123", "level": level, "time": "星期二", "place": "大安區", "number": Int(num), "fee": Int(fee), "author": "me", "type": "volleyball", "allNumber": 8, "address": "台北市信義區"] as [String : Any]
            ref.child("activities").childByAutoId().setValue(value)
        self.navigationController?.popToRootViewController(animated: true)
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.delegate = self
        return false
    }   
}

extension ActivityController {
    func setLabels() {
         nameLabel.text = "Name"
         authorLabel.text = "Author"
         typeLabel.text = "Type"
         levelLabel.text = "Level*"
         timeLabel.text = "Time"
         placeLabel.text = "Place"
         numberLabel.text = "Number*"
         feeLabel.text = "Fee*"
    }
}

