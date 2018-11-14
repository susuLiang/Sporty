//
//  ActivityBasicTableViewCell.swift
//  iSports
//
//  Created by Shu Wei Liang on 2018/11/13.
//  Copyright © 2018 Susu Liang. All rights reserved.
//

import UIKit

protocol ActivityTextFieldDelegate: class {
    func textFieldTextDidChange(cell: UITableViewCell,textField: UITextField)
    func pickerViewSelected(index: Int)
}

class ActivityBasicTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var components: Int = 0
    var numberOfRows: [Int] = []
    var data: [[String]] = []
    var datePicker: UIDatePicker!
    
    var selectedTime: (day: String, hour: String, minute: String) = (day: "", hour: "", minute: "")
    var type: String = ""
    
    weak var delegate: ActivityTextFieldDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.layer.shadowColor = UIColor.gray.cgColor
        textField.layer.shadowRadius = 1
        textField.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        textField.layer.shadowOpacity = 1
        
        textField.layer.cornerRadius = 2
        textField.layer.borderWidth = 1
        textField.layer.borderColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextDidChange(_:)), name: nil, object: textField)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configCell(title: String) {
        titleLabel.text = title
    }
    
    func addPickerView(data: [[String]], components: Int, numberOfRows: [Int]) {
        let picker = UIPickerView()
        textField.inputView = picker
        picker.delegate = self
        picker.dataSource = self
        self.data = data
        self.components = components
        self.numberOfRows = numberOfRows
    }
    
    @objc func textFieldTextDidChange(_ notification: Notification) {
        delegate?.textFieldTextDidChange(cell: self, textField: textField)
    }
    
}

extension ActivityBasicTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return components
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return numberOfRows[component]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            let titleString = NSLocalizedString("Please select", comment: "first row in picker")
            return titleString
        } else {
            return data[component][row - 1]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row != 0 else { return }
        if type == ActivityCellType.time.description {
            switch component {
            case 0: selectedTime.day = time[row-1]
            case 1: selectedTime.hour = hour[row-1]
            case 2:
                selectedTime.minute = minute[row-1]
                if minute[row-1] == "0" {
                    selectedTime.minute = "00"
                }
                
            default: break
            }
            textField.text = "\(selectedTime.day) \(selectedTime.hour) : \(selectedTime.minute)"
        } else if type == ActivityCellType.court.description {
            textField.text = data[component][row - 1]
            delegate?.pickerViewSelected(index: row)
        } else {
            textField.text = data[component][row - 1]
        }
        
    }
    
}
