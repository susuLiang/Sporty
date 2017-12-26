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
    var mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)), camera: GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0))
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    var results: [Activity] = []
    
    var selectedType: String? {
        didSet {
            var selected: [Activity] = []
            for result in results where result.type == selectedType {
                selected.append(result)
            }
            self.view.addSubview(self.setMap(activities: selected))
        }
    }
    
    let searchView = MapSearchController()
    
    var isShowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocation()
        navigationItem.title = "Map"
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-search"), style: .plain, target: self, action: #selector(search))
        navigationItem.rightBarButtonItems = [searchButton]
        navigationController?.navigationBar.tintColor = myWhite

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getLocation() {
        FirebaseProvider.shared.getData(selected: nil, completion: { (results, error) in
            if error == nil {
                self.results = results!
                self.view.addSubview(self.setMap(activities: self.results))
            }
        })
    }
    
    @objc func search() {
        searchView.mainViewController = self
        searchView.view.frame = CGRect(x: UIScreen.main.bounds.width - 150, y: (self.navigationController?.navigationBar.frame.height)! + 20, width: 150, height: UIScreen.main.bounds.height)
        
        if !isShowed {
            self.addChildViewController(searchView)
            self.view.addSubview(searchView.view)
            searchView.didMove(toParentViewController: self)
            isShowed = true
        } else {
            searchView.willMove(toParentViewController: nil)
            searchView.view.removeFromSuperview()
            searchView.removeFromParentViewController()
            isShowed = false
        }
    }
    
    func setMap(activities: [Activity]) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0)
        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)), camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true

        for court in activities {
            var iconName: String = ""
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(court.place.placeLatitude)!, longitude: Double(court.place.placeLongitude)!)
            marker.title = court.id
            marker.opacity = 1

            switch court.type {
            case "羽球": iconName = "badmintonMarker"
            case "棒球": iconName = "baseballMarker"
            case "籃球": iconName = "basketballMarker"
            case "排球": iconName = "volleyballMarker"
            case "網球": iconName = "tennisMarker"
            case "足球": iconName = "soccerMarker"
            default: ""
            }
            marker.icon = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
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
        var selectedActivity: Activity?
        for activity in results {
            if activity.id == marker.title {
                selectedActivity = activity
                break
            }
        }
        let detailView = MapDetailController()
        detailView.selectedPlace = selectedActivity?.place
        detailView.mainViewController = self
        detailView.view.frame = CGRect(x: 0, y: 400, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)

        self.addChildViewController(detailView)
        self.view.addSubview(detailView.view)

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
