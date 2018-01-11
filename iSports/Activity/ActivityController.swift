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

class ActivityController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapPlacedView: UIView!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var levelTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var timeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var courtTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var numberTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var feeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var typeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var allNumberTextField: SkyFloatingLabelTextField!

    var myMatches = [Activity]()

    var myPost: Activity? {
        didSet {
            if let myPost = myPost {
                setText(myPost, isEnable: true)
                self.nowPlace = (myPost.place.placeLatitude, myPost.place.placeLongitude, myPost.address)
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showSaveAlert))
                cityTextField.title = "address"
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
    
    
    @IBAction func addOne(_ sender: Any) {
        save()
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

    override func viewDidLoad() {
        super.viewDidLoad()
//        backView.backgroundColor = myLightBlue
        typeTextField.inputView = typePicker
        cityTextField.inputView = cityPicker
        courtTextField.inputView = courtPicker
        timeTextField.inputView = timePicker
        levelTextField.inputView = levelPicker
        pickerDelegate()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-check"), style: .plain, target: self, action: #selector(save))
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }

    func setText(_ activity: Activity, isEnable: Bool) {
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
        mapPlacedView.addSubview(setMap(latitude: Double(activity.place.placeLatitude)!, longitude: Double(activity.place.placeLongitude)!))

        nameTextField.isEnabled = isEnable
        typeTextField.isEnabled = isEnable
        levelTextField.isEnabled = isEnable
        timeTextField.isEnabled = isEnable
        courtTextField.isEnabled = isEnable
        cityTextField.isEnabled = isEnable
        numberTextField.isEnabled = isEnable
        allNumberTextField.isEnabled = isEnable
        feeTextField.isEnabled = isEnable
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

        self.navigationController?.popToRootViewController(animated: true)
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
        case typePicker: return Sportstype.count
        case cityPicker: return city.count
        case timePicker:
            switch component {
            case 0: return time.count
            case 1: return hour.count
            case 2: return minute.count
            default:
                return 0
            }
        case levelPicker: return levelArray.count
        case courtPicker:
            if courts != nil {
                return courts!.count
            }
            return 0
        default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
