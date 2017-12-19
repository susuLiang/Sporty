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
                addNumberTextField.text = "\(number) / \(allNumber)"
                addFeeTextField.text = "\(fee)"
            }
            if let lat = selectedActivity?.place.placeLatitude, let lng = selectedActivity?.place.placeLongitude{
                mapPlacedView.addSubview(setMap(latitude: Double(lat)!, longitude: Double(lng)!))
            }
        }
    }
    
    let loadingIndicator = LoadingIndicator()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    
    var typePicker = UIPickerView()
    var cityPicker = UIPickerView()
    var courtPicker = UIPickerView()
    var city: [String] = ["臺北市", "新北市", "基隆市", "桃園市", "新竹市", "新竹縣", "苗栗縣", "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "臺南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣" ]
    var type: [String] = ["籃球", "棒球", "羽球", "網球", "足球", "排球" ]
//    var court: [Court]? {
//
//        didSet {
//            courtPicker.reloadAllComponents()
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLabels()
//        addTypeTextField.inputView = typePicker
//        addCityTextField.inputView = cityPicker
//        addPlaceTextField.inputView = courtPicker
//        pickerDelegate()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        switch pickerView {
//        case typePicker: return Sportstype.count
//        case cityPicker: return city.count
//        default: return 1
//        }
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch pickerView {
//        case typePicker: return type[row]
//        case cityPicker: return city[row]
//        case courtPicker:
//        if let type = addTypeTextField.text, let place = addCityTextField.text {
//            return getLocation(city: place, gym: type)[row].name
//        } else {return ""}
//            default: return ""
//        }
//
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        switch pickerView {
//            case typePicker:
//                addTypeTextField.text = type[row]
//            case cityPicker:
//                addCityTextField.text = city[row]
//            default: return
//        }
//    }
    
//    func getLocation(city: String, gym: String) -> [Court] {
//        var courts = [Court]()
//        if let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
//            let gym = gym.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
//            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (Courts, error) in
//                if error == nil {
//                    courts = Courts!
//                } else {
//                    // todo: error handling
//                }
//            })
//
//        }
//        print(courts)
//        return courts
//
//    }
    
    
    @objc func save() {
        
        if (addTypeTextField.text?.isEmpty)! && (addCityTextField.text?.isEmpty)! {
            let alert = UIAlertController(title: "No text", message: "Please Enter Text In The Box", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion:nil)
        }
        
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

//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        textField.delegate = self
//        return false
//    }
    
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
    func setLabels() {
         nameLabel.text = "Name"
         authorLabel.text = "Author"
         typeLabel.text = "Type"
         levelLabel.text = "Level*"
         timeLabel.text = "Time"
         placeLabel.text = "Place"
         numberLabel.text = "Number*"
         feeLabel.text = "Fee*"
         cityLabel.text = "City"
    }
}

//extension ActivityController {
//    func pickerDelegate() {
//        typePicker.delegate = self
//        typePicker.dataSource = self
//        cityPicker.delegate = self
//        cityPicker.dataSource = self
//        courtPicker.delegate = self
//        courtPicker.dataSource = self
//    }
//
//}




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
