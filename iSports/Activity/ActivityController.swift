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
import GooglePlaces
import NVActivityIndicatorView
import KeychainSwift
import SkyFloatingLabelTextField
import SCLAlertView
import LGButton

class ActivityController: UIViewController {

    @IBOutlet weak var addButton: LGButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var feeTextField: UITextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var allNumberLabel: UILabel!
    @IBOutlet weak var allNumberTextField: UITextField!
    @IBOutlet weak var courtLabel: UILabel!
    @IBOutlet weak var courtTextField: UITextField!
    @IBOutlet weak var mapPlacedView: UIImageView!

    var myMatches = [Activity]()

    var myPost: Activity? {
        didSet {
            if let myPost = myPost {
                setText(myPost)
                mapPlacedView.isHidden = true
//                cityLabel.text = NSLocalizedString("ADDRESS", comment: "")
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showSaveAlert))
                cancelButton.isHidden = true
                addButton.isHidden = true
            }
        }
    }

    var nowPlace: (latitude: String, longitude: String, address: String)? {
        didSet {
            if let lat = nowPlace?.latitude, let lng = nowPlace?.longitude {
                mapPlacedView.addSubview(setMap(latitude: Double(lat)!, longitude: Double(lng)!))
            }
        }
    }
    
    @IBAction func cancelAndBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    let loadingIndicator = LoadingIndicator()
    let keyChain = KeychainSwift()

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?

    var uid = Auth.auth().currentUser?.uid

    var typePicker = UIPickerView()
    var cityPicker = UIPickerView()
    var courtPicker = UIPickerView()
    var timePicker = UIPickerView()
    var levelPicker = UIPickerView()

    var thisTime = ""
    var thisHour = ""
    var thisMinute = ""

    var courts: [Court]? {
        didSet {
            courtPicker.reloadAllComponents()
        }
    }
    @IBAction func add(_ sender: Any) {
        save()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldDelegate()
        setLabelText()
        setPickerView()
        setTextField(cornerRadius: 10)
        pickerDelegate()
        addButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    func setPickerView() {
        typeTextField.inputView = typePicker
        cityTextField.inputView = cityPicker
        courtTextField.inputView = courtPicker
        timeTextField.inputView = timePicker
        levelTextField.inputView = levelPicker
    }

    func setText(_ activity: Activity) {
        navigationItem.title = activity.name
        nameTextField.text = activity.name
        typeTextField.text = activity.type
        levelTextField.text = activity.level
        timeTextField.text = activity.time
        courtTextField.text = activity.place.placeName
        cityTextField.text = activity.address
        numberTextField.text = "\(activity.number)"
        allNumberTextField.text = "\(activity.allNumber)"
        feeTextField.text = "\(activity.fee)"
        self.nowPlace = (activity.place.placeLatitude ,activity.place.placeLongitude, activity.address)

//        mapPlacedView.addSubview(setMap(latitude: Double(activity.place.placeLatitude)!, longitude: Double(activity.place.placeLongitude)!))
    }

    func setTextField(cornerRadius: CGFloat) {
        nameTextField.layer.cornerRadius = cornerRadius
        typeTextField.layer.cornerRadius = cornerRadius
        levelTextField.layer.cornerRadius = cornerRadius
        timeTextField.layer.cornerRadius = cornerRadius
        courtTextField.layer.cornerRadius = cornerRadius
        cityTextField.layer.cornerRadius = cornerRadius
        numberTextField.layer.cornerRadius = cornerRadius
        allNumberTextField.layer.cornerRadius = cornerRadius
        feeTextField.layer.cornerRadius = cornerRadius
    }

    func getLocation(city: String, gym: String) {
        loadingIndicator.start()
        if let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let gym = gym.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (courts, error) in
                if error == nil {
                    self.courts = courts!
                } else {
                    // todo: error handling
                }
                self.loadingIndicator.stop()
            })
        }
    }

    @objc func showSaveAlert() {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton(NSLocalizedString("SURE", comment: ""), action: self.change)
        alertView.addButton(NSLocalizedString("NO", comment: "")) {
        }
        alertView.showWarning(NSLocalizedString("Sure to save it ?", comment: ""), subTitle: "")
    }

    func change() {

        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: date as Date)

        guard
            let level = self.levelTextField.text,
            let num = self.numberTextField.text,
            let fee = self.feeTextField.text,
            let court = self.courtTextField.text,
            let name = self.nameTextField.text,
            let type = self.typeTextField.text,
            let time = self.timeTextField.text,
            let allnum = allNumberTextField.text
            else {
                print("Form is not valid")
                return
        }
        let ref = Database.database().reference()
        let refChild = ref.child("activities")
        let uid = self.keyChain.get("uid")
        let postedTime: String = dateString
        guard let activityUid = self.myPost?.id,
            let authorName = self.keyChain.get("name"),
            let lat = self.nowPlace?.latitude,
            let lng = self.nowPlace?.longitude,
            let address = self.nowPlace?.address else {
                return
            }
        let value = ["name": name, "level": level, "time": time,
                 "place": court, "number": Int(num), "fee": Int(fee),
                 "author": authorName, "type": type, "allNumber": Int(allnum),
                 "address": address, "userUid": uid, "latitude": lat,
                 "longitude": lng, "postedTime": postedTime] as [String: Any]
        refChild.child(activityUid).updateChildValues(value)

        SCLAlertView().showSuccess(NSLocalizedString("Saved !", comment: ""), subTitle: "")
    }

    @objc func save() {
        guard
            let level = levelTextField.text,
            let num = numberTextField.text,
            let fee = feeTextField.text,
            let place = courtTextField.text,
            let name = nameTextField.text,
            let type = typeTextField.text,
            let time = timeTextField.text,
            let allnum = allNumberTextField.text
            else {
                print("Form is not valid")
                return
            }

        if level == "" || num == "" || fee == "" || place == "" || name == "" || type == "" || time == "" || allnum == "" {
           SCLAlertView().showError(NSLocalizedString("Please fill up the blank.", comment: ""), subTitle: "")
            return
        }

        let ref = Database.database().reference()
        let refChild = ref.child("activities")
        let uid = keyChain.get("uid")
        let authorName = keyChain.get("name")
        let lat = nowPlace?.latitude
        let lng = nowPlace?.longitude
        let address = nowPlace?.address
        let value = ["name": name, "level": level, "time": time,
                     "place": place, "number": Int(num), "fee": Int(fee),
                     "author": authorName, "type": type, "allNumber": Int(allnum),
                     "address": address, "userUid": uid, "latitude": lat,
                     "longitude": lng, "postedTime": "\(Date())"] as [String: Any]
        let childRef = refChild.childByAutoId()
        childRef.setValue(value)
        ref.child("user_postId").childByAutoId().setValue(["user": uid, "postId": childRef.key])
        self.dismiss(animated: true, completion: nil)
    }

    func setLabelText() {
        nameLabel.text = NSLocalizedString("NAME", comment: "")
        levelLabel.text = NSLocalizedString("LEVEL", comment: "")
        typeLabel.text = NSLocalizedString("TYPE", comment: "")
        timeLabel.text = NSLocalizedString("TIME", comment: "")
        courtLabel.text = NSLocalizedString("COURT", comment: "")
        cityLabel.text = NSLocalizedString("CITY", comment: "")
        feeLabel.text = NSLocalizedString("FEE", comment: "")
        numberLabel.text = NSLocalizedString("NUMBER", comment: "")
        allNumberLabel.text = NSLocalizedString("ALL NUMBER", comment: "")

    }

}

extension ActivityController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = .white
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowRadius = 5
        textField.layer.shadowOpacity = 0.5
        return true
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.backgroundColor = UIColor.groupTableViewBackground
        textField.layer.shadowOpacity = 0
        return true
    }

    func textFieldDelegate() {
        nameTextField.delegate = self
        levelTextField.delegate = self
        cityTextField.delegate = self
        numberTextField.delegate = self
        allNumberTextField.delegate = self
        feeTextField.delegate = self
        timeTextField.delegate = self
        courtTextField.delegate = self
        typeTextField.delegate = self
    }
}

extension ActivityController: UIPickerViewDelegate, UIPickerViewDataSource {

    func pickerDelegate() {
        typePicker.delegate = self
        typePicker.dataSource = self
        cityPicker.delegate = self
        cityPicker.dataSource = self
        courtPicker.delegate = self
        courtPicker.dataSource = self
        timePicker.delegate = self
        timePicker.dataSource = self
        levelPicker.delegate = self
        levelPicker.dataSource = self
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case typePicker, cityPicker, levelPicker:
            return 1
        case timePicker:
            return 3
        case courtPicker:
            if (typeTextField.text == "") || (cityTextField.text == "") {
//                if self.presentedViewController == nil {
//                    let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
//                    let alertView = SCLAlertView(appearance: appearance)
//                    alertView.addButton("OK", action: {
//                        self.courtTextField.endEditing(true)
//                        self.typeTextField.becomeFirstResponder()
//                    })
//                    alertView.showWarning("Please choose the type and city first.", subTitle: "")
//                }
                let alert = UIAlertController(title: NSLocalizedString("No text", comment: ""), message: NSLocalizedString("Please choose the type and city first.", comment: ""), preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: { _ in
                    self.courtTextField.endEditing(true)
                    self.typeTextField.becomeFirstResponder()
                })
                alert.addAction(defaultAction)

                if self.presentedViewController == nil {
                    self.present(alert, animated: true, completion: nil)
                }
                return 0
            } else if courts != nil {
                courtPicker.isHidden = false
                return 1
            }

        default:
            return 1
        }
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case typePicker: return Sportstype.count + 1
        case cityPicker: return city.count + 1
        case timePicker:
            switch component {
            case 0: return time.count + 1
            case 1: return hour.count + 1
            case 2: return minute.count + 1
            default:
                return 0
            }
        case levelPicker: return levelArray.count + 1
        case courtPicker:
            if courts != nil {
                return courts!.count + 1
            }
            return 0
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            let titleString = NSLocalizedString("Please select", comment: "first row in picker")
            return titleString
        } else {
            let row = row - 1
            
            switch pickerView {
            case typePicker: return typeArray[row]
            case cityPicker: return city[row]
            case timePicker:
                switch component {
                case 0: return time[row]
                case 1: return String(hour[row])
                case 2: return String(minute[row])
                default:
                return ""
            }
            case levelPicker: return levelArray[row]
            case courtPicker:
                if courts != nil {
                    return courts?[row].name
                } else {
                    return ""
                }
            default: return ""
            }
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != 0 {
            let row = row - 1
            switch pickerView {
            case typePicker:
                typeTextField.text = typeArray[row]
                if cityTextField.text != "" {
                    if let type = typeTextField.text, let place = cityTextField.text {
                        getLocation(city: place, gym: type)
                    }
                }

            case cityPicker:
                cityTextField.text = city[row]
                if typeTextField.text != "" {
                    if let type = typeTextField.text, let place = cityTextField.text {
                        getLocation(city: place, gym: type)
                    }
                }

            case courtPicker:
                courtTextField.text = courts![row].name
                self.nowPlace = (courts![row].latitude, courts![row].longitude, courts![row].address)

            case levelPicker:
                levelTextField.text = levelArray[row]

            case timePicker:
                switch component {
                case 0: thisTime = time[row]
                case 1: thisHour = String(hour[row])
                case 2:
                    if minute[row] == 0 {
                        thisMinute = "00"
                    } else {
                        thisMinute = String(minute[row])
                    }

                default:
                    break
                }
                timeTextField.text = "\(thisTime) \(thisHour) : \(thisMinute)"
            default: return
            }
        }
    }
}

extension ActivityController: CLLocationManagerDelegate {

    func setMap(latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: courtTextField.frame.width, height: mapPlacedView.frame.height), camera: camera)

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView

        setLocationManager()
        return mapView
    }

    func setLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.placesClient = GMSPlacesClient.shared()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
    }
}
