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

    @IBOutlet weak var mapPlacedView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var levelTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var timeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var courtTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var numberTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var feeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var typeTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var allNumberTextField: SkyFloatingLabelTextField!
    
    @IBAction func join(_ sender: UIButton) {
        sender.tintColor = UIColor.gray
        let ref = Database.database().reference()
        if let selected = selectedActivity {
            let joinId = selected.id
            let newVaule = selected.number + 1
            
            ref.child("user_joinId").childByAutoId().setValue(["user": uid, "joinId": joinId])
            ref.child("activities").child(joinId).child("number").setValue(newVaule)
        }
    }
    
    var myMatches = [Activity]()

    var selectedActivity: Activity?  {
        didSet {
            if let selectedActivity = selectedActivity {
                setText(selectedActivity, isEnable: false, disabledColor: myBlack)
                setJoinButton()
                navigationItem.rightBarButtonItem = nil
                cityTextField.title = "address"
            }
        }
    }
    
    var myPost: Activity?  {
        didSet {
            if let myPost = myPost {
                setText(myPost, isEnable: true, disabledColor: myBlue)
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showAlert))
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
    
    let loadingIndicator = LoadingIndicator()
    
    let getPostIndicator = LoadingIndicator()
    
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
    
    var courts: [Court]? {
        didSet {
            courtPicker.reloadAllComponents()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
        typeTextField.inputView = typePicker
        cityTextField.inputView = cityPicker
        courtTextField.inputView = courtPicker
        timeTextField.inputView = timePicker
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
    
    func setText(_ activity: Activity, isEnable: Bool, disabledColor: UIColor) {
        navigationItem.title = activity.name
        nameTextField.text = activity.name
        typeTextField.text = activity.type
        levelTextField.text = activity.level.rawValue
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
        
        nameTextField.disabledColor = disabledColor
        typeTextField.disabledColor = disabledColor
        levelTextField.disabledColor = disabledColor
        timeTextField.disabledColor = disabledColor
        courtTextField.disabledColor = disabledColor
        cityTextField.disabledColor = disabledColor
        numberTextField.disabledColor = disabledColor
        allNumberTextField.disabledColor = disabledColor
        feeTextField.disabledColor = disabledColor
    }
    
    func getLocation(city: String, gym: String) {
        loadingIndicator.start()
        if let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let gym = gym.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (Courts, error) in
                if error == nil {
                    self.courts = Courts!
                } else {
                    // todo: error handling
                }
                self.loadingIndicator.stop()
            })

        }
    }
    
    func getPosts() {
        FirebaseProvider.shared.getPosts(childKind: "joinId", completion: { (posts, keyUid, error) in
            self.myMatches = posts!
            self.setJoinButton()
        })
    }
    
    func setJoinButton() {
        let joinIcon = UIImage(named: "icon-join-big")?.withRenderingMode(.alwaysTemplate)
        var isMyMatch = false
        
        if let selected = selectedActivity {

            if selected.authorUid != uid {
                for myMatch in myMatches where myMatch.id == selected.id {
                    isMyMatch = true
                }
                if selected.number < selected.allNumber && !isMyMatch {
                    joinButton.isEnabled = true
                    joinButton.setImage(joinIcon, for: .normal)
                    joinButton.tintColor = myRed
                    joinButton.addTarget(self, action: #selector(self.join), for: .touchUpInside)
                } else {
                    joinButton.isEnabled = false
                    joinButton.setImage(joinIcon, for: .normal)
                    joinButton.tintColor = UIColor.gray
                }
                
            } else {
                joinButton.isEnabled = false
                joinButton.setImage(joinIcon, for: .normal)
                joinButton.tintColor = UIColor.clear
            }
        }
    }
    
    @objc func showAlert() {
        let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("SURE", action: self.change)
        alertView.addButton("NO") {
        }
        alertView.showWarning("Sure to save it ?", subTitle: "")
    }
    
    func change() {
        guard
            let level = self.levelTextField.text,
            let num = self.numberTextField.text,
            let fee = self.feeTextField.text,
            let court = self.courtTextField.text,
            let name = self.nameTextField.text,
            let type = self.typeTextField.text,
            let time = self.timeTextField.text
            else {
                print("Form is not valid")
                return
        }
        let ref = Database.database().reference()
        let refChild = ref.child("activities")
        let uid = self.keyChain.get("uid")
        guard let activityUid = self.myPost?.id,
            let authorName = self.keyChain.get("name"),
            let lat = self.nowPlace?.latitude,
            let lng = self.nowPlace?.longitude,
            let address = self.nowPlace?.address else {
                return
            }
        let value = ["name": name, "level": level, "time": time,
                 "place": court, "number": Int(num), "fee": Int(fee),
                 "author": authorName, "type": type, "allNumber": 8,
                 "address": address, "userUid": uid, "latitude": lat,
                 "longitude": lng] as [String : Any]
        refChild.child(activityUid).updateChildValues(value)
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @objc func save() {
        
        if (typeTextField.text?.isEmpty)! && (cityTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "No text", message: "Please Enter Text In The Box", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion:nil)
        }
        
        guard
            let level = levelTextField.text,
            let num = numberTextField.text,
            let fee = feeTextField.text,
            let place = courtTextField.text,
            let name = nameTextField.text,
            let type = typeTextField.text,
            let time = timeTextField.text
            else {
                print("Form is not valid")
                return
            }
        let ref = Database.database().reference()
        let refChild = ref.child("activities")
        let uid = keyChain.get("uid")
        let authorName = keyChain.get("name")
        let lat = nowPlace?.latitude
        let lng = nowPlace?.longitude
        let address = nowPlace?.address
        let value = ["name": name, "level": level, "time": "星期二",
                     "place": place, "number": Int(num), "fee": Int(fee),
                     "author": authorName, "type": type, "allNumber": 8,
                     "address": address, "userUid": uid, "latitude": lat,
                     "longitude": lng] as [String : Any]
        let childRef = refChild.childByAutoId()
        childRef.setValue(value)
        ref.child("user_postId").childByAutoId().setValue(["user": uid, "postId": childRef.key])
        
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    func setMap(latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: mapPlacedView.frame.width, height: mapPlacedView.frame.height), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
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
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case typePicker, cityPicker, timePicker:
            return 1
        case courtPicker:
            courtPicker.isHidden = true
            if (typeTextField.text == "") || (cityTextField.text == "") {
                let alert = UIAlertController(title: "No text", message: "Please Enter Text In The Box", preferredStyle: .alert)
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
        case timePicker: return time.count
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
        case timePicker: return time[row]
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
            
        case timePicker:
            timeTextField.text = time[row]
        default: return
        }
    }
}

extension ActivityController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = mapView
        
    }
}
