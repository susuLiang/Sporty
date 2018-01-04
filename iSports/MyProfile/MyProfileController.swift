//
//  MyProfileController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/21.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import KeychainSwift
import SkyFloatingLabelTextField
import Fusuma
import SCLAlertView
import Nuke
import NVActivityIndicatorView

class MyProfileController: UIViewController, UITextFieldDelegate {

    var cell: MyProfileCell?

    var loadingIndicator = LoadingIndicator()

    let keyChain = KeychainSwift()

    let fusuma = FusumaViewController()

    var userImage = UIImage()

    var userSetting: UserSetting?

    var settingType = ["Profile", "Preference"]

    var settingIconName = ["profile-user", "profile-setting"]

    var isEdit = false

    var isExpanded = [false, false]

    var selectedIndexPath: IndexPath?

    var typePicker = UIPickerView()
    var timePicker = UIPickerView()
    var levelPicker = UIPickerView()
    var cityPicker = UIPickerView()

     @IBAction func pickPhoto(_ sender: Any) {
        self.present(fusuma, animated: true, completion: nil)
    }

    @IBOutlet weak var blurBackView: UIImageView!
    @IBOutlet weak var photoPickButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBAction func logOut(_ sender: Any) {

        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("SURE", action: {
            self.keyChain.clear()
            do {
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
            self.present(loginController, animated: true, completion: nil)

        })
        alertView.addButton("NO") {}
        alertView.showWarning("Sure to log out ?", subTitle: "")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingIndicator.start()

        pickerDelegate()
        getUserProfile()

        setupTableCell()

        fusuma.delegate = self
        fusuma.cropHeightRatio = 0.6

        setNavigationBar()
        setLogOutButton()

        nameLabel.text = keyChain.get("name")
        userPhoto.layer.cornerRadius = 100
        userPhoto.clipsToBounds = true

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurBackView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurBackView.addSubview(blurEffectView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getUserProfile() {
        FirebaseProvider.shared.getUserProfile(completion: { (userSetting, error) in
            self.loadingIndicator.start()
            if error == nil {
                self.userSetting = userSetting
                self.nameLabel.text = self.userSetting?.name
                if userSetting?.urlString != nil {
                    self.loadUserPhoto()
                }
            }
            self.loadingIndicator.stop()
        })
    }

    func loadUserPhoto() {
        Nuke.loadImage(with: URL(string: (self.userSetting?.urlString)!)!, into: self.userPhoto,
                       handler: { (response, _) in
            self.userPhoto?.image = response.value
        })
        Nuke.loadImage(with: URL(string: (self.userSetting?.urlString)!)!, into: self.blurBackView,
                       handler: { (response, _) in
            self.blurBackView?.image = response.value
            self.loadingIndicator.stop()
        })
        self.userPhoto.contentMode = .scaleAspectFill
    }

    @objc func showBack() {
        navigationController?.popViewController(animated: true)
    }

    func setLogOutButton() {
        logOutButton.layer.cornerRadius = 20
        logOutButton.layer.shadowRadius = 5
    }

    @objc func edit() {
        let saveIcon = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showSaveAlert))
        navigationItem.rightBarButtonItem = saveIcon
        photoPickButton.isEnabled = true
        userPhoto.layer.borderWidth = 3
        userPhoto.layer.borderColor = myBlack.cgColor
        isEdit = true
        tableView.reloadData()
        photoPickButton.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
    }

    @objc func showAlert() {
        let editIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-edit"), style: .plain, target: self, action: #selector(edit))
        navigationItem.rightBarButtonItem = editIt

        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("SURE", action: self.save)
        alertView.addButton("NO") {
            let saveIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(self.edit))
            self.isEdit = true
            self.navigationItem.rightBarButtonItem = saveIt
        }
        alertView.showWarning("Sure to save it ?", subTitle: "")
    }

    func save() {
        userPhoto.layer.borderWidth = 0

        guard let userUid = keyChain.get("uid") else { return }

        let userRef = Database.database().reference().child("users").child(userUid)
        if selectedIndexPath != nil {
            if let cell = tableView.cellForRow(at: selectedIndexPath!) as? MyProfileCell {
                cell.nameSettimgTextField.isEnabled = false
                cell.typeSettingTextField.isEnabled = false
                cell.citySettingTextField.isEnabled = false
                cell.levelSettingTextField.isEnabled = false
                cell.timeSettingTextField.isEnabled = false

                let name = cell.nameSettimgTextField.text
                let type = cell.typeSettingTextField.text
                let city = cell.citySettingTextField.text
                let level = cell.levelSettingTextField.text
                let time = cell.timeSettingTextField.text
                let value = ["name": name]
                let preferenceValue = ["type": type, "city": city, "level": level, "time": time]
                userRef.updateChildValues(value)
                userRef.child("preference").updateChildValues(preferenceValue)
            }
        }
        var data = Data()
        if userPhoto.image != nil {
            data = UIImageJPEGRepresentation(userPhoto.image!, 0.6)!
            let ref = Database.database().reference()
            let storageRef = Storage.storage().reference()
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpg"
            storageRef.child(userUid).putData(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata else {
                    // Todo: error handling
                    return
                }
                let downloadURL = metadata.downloadURL()?.absoluteString
                let value = ["imageURL": downloadURL]
                ref.child("users").child(userUid).updateChildValues(value)
            }
        }
        self.photoPickButton.isEnabled = false
        self.isEdit = false
        self.tableView.reloadData()
    }

    func setNavigationBar() {
        let myProfile = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-menu"), style: .plain, target: self, action: #selector(showBack))
        let editIt = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-edit"), style: .plain, target: self, action: #selector(edit))
        navigationItem.leftBarButtonItems = [myProfile]
        navigationItem.rightBarButtonItem = editIt
    }

}

extension MyProfileController: UITableViewDelegate, UITableViewDataSource {
    func setupTableCell() {
        let nib = UINib(nibName: "MyProfileCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return settingType.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyProfileCell else {
            fatalError("Invalid MyProfileCell") }
        self.cell = cell
        cell.cellLabel?.text = settingType[indexPath.section]
        cell.accessoryType = .disclosureIndicator
        cell.cellLabel?.font = UIFont(name: "ArialHebrew-Bold", size: 18)
        cell.lableImage?.image = UIImage(named: "\(settingIconName[indexPath.section])")
        if let user = userSetting {
            cell.set(userSetting: user)
        }

        cell.typeSettingTextField.inputView = typePicker
        cell.levelSettingTextField.inputView = levelPicker
        cell.citySettingTextField.inputView = cityPicker
        cell.timeSettingTextField.inputView = timePicker

        if isExpanded[indexPath.section] {
            switch indexPath.section {
            case indexPath.section:
                cell.profileView.isHidden = !isExpanded[0]
                cell.preferenceView.isHidden = !isExpanded[1]
            default:
                cell.profileView.isHidden = true
                cell.preferenceView.isHidden = true
            }
        }

        if isEdit {
            cell.nameSettimgTextField.isEnabled = true
            cell.citySettingTextField.isEnabled = true
            cell.typeSettingTextField.isEnabled = true
            cell.timeSettingTextField.isEnabled = true
            cell.levelSettingTextField.isEnabled = true
        } else {
            cell.nameSettimgTextField.isEnabled = false
            cell.citySettingTextField.isEnabled = false
            cell.typeSettingTextField.isEnabled = false
            cell.timeSettingTextField.isEnabled = false
            cell.levelSettingTextField.isEnabled = false
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isExpanded[indexPath.section] {
            return 192
        } else {
            return 68
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch indexPath.section {
        case 0:
            isExpanded[0] = !isExpanded[0]
            isExpanded[1] = false
            break
        case 1:
            isExpanded[1] = !isExpanded[1]
            isExpanded[0] = false
            break
        default:
            break
        }
        self.tableView.beginUpdates()
        self.tableView.reloadData()
        self.tableView.endUpdates()
    }

}

extension MyProfileController: FusumaDelegate {

    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        userPhoto.image = image
        blurBackView.image = image
        self.userImage = image
        userPhoto.contentMode = .scaleAspectFill
        blurBackView.contentMode = .scaleAspectFill
    }

    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }

    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    }

    func fusumaCameraRollUnauthorized() {
    }

}

extension MyProfileController: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerDelegate() {
        typePicker.delegate = self
        typePicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
        timePicker.delegate = self
        timePicker.dataSource = self
        cityPicker.delegate = self
        cityPicker.dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case typePicker: return Sportstype.count
        case cityPicker: return city.count
        case timePicker: return time.count
        case levelPicker: return levelArray.count
        default:
            return 1
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case typePicker: return typeArray[row]
        case cityPicker: return city[row]
        case timePicker: return time[row]
        case levelPicker: return levelArray[row]
        default:
            return ""
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case typePicker:
            cell?.typeSettingTextField.text = typeArray[row]

        case cityPicker:
            cell?.citySettingTextField.text = city[row]

        case levelPicker:
            cell?.levelSettingTextField.text = levelArray[row]

        case timePicker:
            cell?.timeSettingTextField.text = time[row]

        default: return
        }
    }
}
