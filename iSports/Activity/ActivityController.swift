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
                addNameTextField.text = "\(number) / \(allNumber)"
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
