//
//  MapController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapController: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    var courts: [Court] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getLocation() {
        if let city = "臺北市".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let gym = "羽球場".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (Courts, error) in
                if error == nil {
                    self.courts = Courts!
                    self.view.addSubview(self.setMap(latitude: 25.0472, longitude: 121.564939))
                } else {
                    // todo: error handling
                }
            })
        }
        
    }
    
    func setMap(latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)), camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        for court in self.courts {
            print(court.latitude)
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(court.latitude)!, longitude: Double(court.longitude)!)
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.map = mapView
        }
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

extension MapController: CLLocationManagerDelegate {
    
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
