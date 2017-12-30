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

class ActivityController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mapPlacedView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var courtTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var feeTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var allNumberTextField: UITextField!
    
    var selectedActivity: Activity?  {
        didSet {
            navigationItem.rightBarButtonItem = nil
            navigationItem.title = selectedActivity?.name
            nameTextField.text = selectedActivity?.name
            typeTextField.text = selectedActivity?.type
            levelTextField.text = selectedActivity?.level.rawValue
            timeTextField.text = selectedActivity?.time
            courtTextField.text = selectedActivity?.place.placeName
            if let number = selectedActivity?.number,
                let allNumber = selectedActivity?.allNumber,
                let fee = selectedActivity?.fee
            {
                numberTextField.text = "\(number)"
                allNumberTextField.text = "\(allNumber)"
                feeTextField.text = "\(fee)"
            }
            if let lat = selectedActivity?.place.placeLatitude, let lng = selectedActivity?.place.placeLongitude{
                mapPlacedView.addSubview(setMap(latitude: Double(lat)!, longitude: Double(lng)!))
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
    
    let keyChain = KeychainSwift()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    
    var typePicker = UIPickerView()
    var cityPicker = UIPickerView()
    var courtPicker = UIPickerView()
    var courts: [Court]? {

        didSet {
            courtPicker.reloadAllComponents()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        typeTextField.inputView = typePicker
        cityTextField.inputView = cityPicker
        courtTextField.inputView = courtPicker
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerView {
        case typePicker, cityPicker:
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
        default: return
        }
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
        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 10), size: CGSize(width: view.frame.width, height: 300)), camera: camera)
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

extension ActivityController {
//    func setLabels() {
//        nameLabel.text = "Name"
//        authorLabel.text = "Author"
//        typeLabel.text = "Type"
//        levelLabel.text = "Level*"
//        timeLabel.text = "Time"
//        placeLabel.text = "Place"
//        numberLabel.text = "Number*"
//        feeLabel.text = "Fee*"
//        cityLabel.text = "City"
//        let name = keyChain.get("name")
//        authorName.text = name
//    }
}

extension ActivityController {
    func pickerDelegate() {
        typePicker.delegate = self
        typePicker.dataSource = self
        cityPicker.delegate = self
        cityPicker.dataSource = self
        courtPicker.delegate = self
        courtPicker.dataSource = self
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
