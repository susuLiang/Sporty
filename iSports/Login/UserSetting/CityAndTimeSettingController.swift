//
//  CitySettingController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/26.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase

enum SettingType {

    case city, time

}

class CityAndTimeSettingController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var titleSubLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sureButton: UIButton!

    var selected: String? = ""

    var controllerType: SettingType = .city

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        sureButton.layer.cornerRadius = 10
        view.backgroundColor = myBlack
        tableView.backgroundColor = myBlack
        switch controllerType {
        case .city:
            titleLabel.text = NSLocalizedString("3 / 4 City", comment: "")
            titleSubLabel.text = NSLocalizedString("Where you live in?", comment: "")
        case .time:
            titleLabel.text = NSLocalizedString("4 / 4 Time", comment: "")
            titleSubLabel.text = NSLocalizedString("When are you available?", comment: "")
        }

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
            return cityArray.count
        case .time:
            return time.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as? CityAndTimeSettingCell else {
            fatalError("CityAndTimeSettingCell invalid")
        }
        switch controllerType {
        case .city:
            cell.textLabel?.text = cityArray[indexPath.row]
        case .time:
            cell.textLabel?.text = time[indexPath.row]
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch controllerType {
        case .city:
            self.selected = cityArray[indexPath.row]
        case .time:
            self.selected = time[indexPath.row]
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch controllerType {
        case .city:
            return 44
        case .time:
            return 60
        }
    }

    @IBAction func saveUserCity(_ sender: Any) {

        switch controllerType {
        case .city:

            let value = self.selected
            if let userUid = UserDefaults.standard.string(forKey: UserDefaultKey.uid.rawValue) {

                let ref = Database.database().reference().child("users").child(userUid)

                ref.child("preference").child("city").setValue(value)

                let storyboard = UIStoryboard(name: "Main", bundle: nil)

                guard let cityAndTimeSettingController = storyboard.instantiateViewController(withIdentifier: "cityAndTimeSettingController") as? CityAndTimeSettingController else {
                    print("CityAndTimeSettingController invalid")
                    return
                }

                cityAndTimeSettingController.controllerType = .time

                self.present(cityAndTimeSettingController, animated: true, completion: nil)
            }
            break
        case .time:
                let value = self.selected

                if let userUid = UserDefaults.standard.string(forKey: UserDefaultKey.uid.rawValue) {

                    let ref = Database.database().reference().child("users").child(userUid)

                    ref.child("preference").child("time").setValue(value)

                    let tabBarController = TabBarController(itemTypes: [ .home, .map, .my, .setting])

                    tabBarController.selectedIndex = 0

                    self.present(tabBarController, animated: true, completion: nil)

                    break
            }

        }
    }
}
