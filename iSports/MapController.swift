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

class MapController: UIViewController, GMSMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
//    var courts: [Court] = []
    var results: [Activity] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        navigationItem.title = "Map"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getLocation() {
        FirebaseProvider.shared.getData(selected: nil, completion: { (results, error) in
            if error == nil {
                self.results = results!
                self.view.addSubview(self.setMap())
            }
        })
    }
//        if let city = "臺北市".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
//            let gym = "羽球場".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
//            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (Courts, error) in
//                if error == nil {
//                    self.courts = Courts!
//                    self.view.addSubview(self.setMap(latitude: 25.0472, longitude: 121.564939))
//                } else {
//                    // todo: error handling
//                }
//            })
//        }
    
    
    func setMap() -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0)
        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)), camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        for court in self.results {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(court.place.placeLatitude)!, longitude: Double(court.place.placeLongitude)!)
            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.title = court.id
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
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var didSelectedMarker: Activity?
        for activity in results {
            if activity.id == marker.title {
                didSelectedMarker = activity
                break
            }
        }
        let activityView = UINib.load(nibName: "ActivityView") as! ActivityController
        activityView.selectedActivity = didSelectedMarker

        navigationController?.pushViewController(activityView, animated: true)
        return true
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
