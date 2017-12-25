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

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}

class MapController: UIViewController, GMSMapViewDelegate, GMUClusterManagerDelegate {
        
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)), camera: GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0))
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    var results: [Activity] = []
    var clusterManager: GMUClusterManager!
    
    let searchView = MapSearchController()
    
    var isShowed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let camera = GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0)
////        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)), camera: camera)
////        let camera = GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0)
//        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)), camera: GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0))
////        mapView.delegate = self
////        mapView.isMyLocationEnabled = true
////        mapView.settings.myLocationButton = true
//        mapView.delegate = self
//        mapView.isMyLocationEnabled = true
//        mapView.settings.myLocationButton = true
//        view.addSubview(mapView)
//        setLocationManager()
        
        getLocation()
//        clusterManager.setDelegate(self, mapDelegate: self)
//        setCluster()
        navigationItem.title = "Map"
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-search"), style: .plain, target: self, action: #selector(search))
        navigationItem.rightBarButtonItems = [searchButton]
        navigationController?.navigationBar.tintColor = myGreen

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getLocation() {
        FirebaseProvider.shared.getData(selected: nil, completion: { (results, error) in
            if error == nil {
                self.results = results!
//                self.setMarker()
//                self.view.addSubview(self.mapView)

                self.view.addSubview(self.setMap())
            }
        })
    }
    
    @objc func search() {
        searchView.mainViewController = self
        searchView.view.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: 200, height: UIScreen.main.bounds.height)
        
        if !isShowed {
            self.addChildViewController(searchView)
            self.mapView.addSubview(searchView.view)
            searchView.didMove(toParentViewController: self)
            isShowed = true
        } else {
            searchView.willMove(toParentViewController: nil)
            searchView.view.removeFromSuperview()
            searchView.removeFromParentViewController()
            isShowed = false
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//
//        super.viewWillDisappear(animated)
//
//        print(self.mapView)
//    }
//
    
//    func setMarker() {
//        for court in self.results {
//            var iconName: String = ""
//            let marker = GMSMarker()
//            marker.position = CLLocationCoordinate2D(latitude: Double(court.place.placeLatitude)!, longitude: Double(court.place.placeLongitude)!)
//            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
//            marker.title = court.id
//            marker.opacity = 1
//
//            switch court.type {
//            case "羽球": iconName = "badmintonMarker"
//            case "棒球": iconName = "baseballMarker"
//            case "籃球": iconName = "basketballMarker"
//            case "排球": iconName = "volleyballMarker"
//            case "網球": iconName = "tennisMarker"
//            case "足球": iconName = "soccerMarker"
//            default: ""
//            }
//            marker.icon = UIImage(named: iconName)
//
//            marker.map = mapView
//        }
//
//    }
    func setMap() -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0)
        let mapView = GMSMapView.map(withFrame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)), camera: camera)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true

        for court in self.results {
            var iconName: String = ""
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: Double(court.place.placeLatitude)!, longitude: Double(court.place.placeLongitude)!)
//            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
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
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {

        guard let infoWindow = Bundle.main.loadNibNamed("MapInfo", owner: self, options: nil)?.first as? MapInfo else {
            return UIView()
        }
        infoWindow.bounds = CGRect(x: 0, y: 0, width: mapView.frame.width * 0.5, height: mapView.frame.height * 0.2)

        infoWindow.titleLabel.text = "\(marker.position.latitude) \(marker.position.longitude)"
        return infoWindow
    }

//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
//        guard let infoWindow = UIView.load(nibName: "MapInfo") as? MapInfo else {
//            return UIView()
//        }
//        infoWindow.bounds = CGRect(x: 0, y: 0, width: mapView.frame.width * 0.5, height: mapView.frame.height * 0.2)
//
//        infoWindow.titleLabel.text = "\(marker.position.latitude) \(marker.position.longitude)"
//        return infoWindow
//    }
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
    
    
    
//    func setCluster() {
//        // Set up the cluster manager with the supplied icon generator and
//        // renderer.
//        let iconGenerator = GMUDefaultClusterIconGenerator()
//        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
//        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
//                                                 clusterIconGenerator: iconGenerator)
//        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm,
//                                           renderer: renderer)
//
//        // Generate and add random items to the cluster manager.
//        generateClusterItems()
//
//        // Call cluster() after items have been added to perform the clustering
//        // and rendering on map.
//        clusterManager.cluster()
//
//    }
//
//    private func generateClusterItems() {
//        let extent = 0.2
//        for index in 1...results.count {
//            let lat = Double(results[index].place.placeLatitude)! + extent * randomScale()
//            let lng = Double(results[index].place.placeLongitude)! + extent * randomScale()
//            let name = "Item \(index)"
//            let item =
//                POIItem(position: CLLocationCoordinate2DMake(lat, lng), name: name)
//            clusterManager.add(item)
//        }
//    }
//
//    /// Returns a random value between -1.0 and 1.0.
//    private func randomScale() -> Double {
//        return Double(arc4random()) / Double(UINT32_MAX) * 2.0 - 1.0
//    }
//    // MARK: - GMUClusterManagerDelegate
//
//    func clusterManager(clusterManager: GMUClusterManager, didTapCluster cluster: GMUCluster) {
//        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
//                                                           zoom: mapView.camera.zoom + 1)
//        let update = GMSCameraUpdate.setCamera(newCamera)
//        mapView.moveCamera(update)
//    }
//
//    // MARK: - GMUMapViewDelegate
//
//    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
//        if let poiItem = marker.userData as? POIItem {
//            NSLog("Did tap marker for cluster item \(poiItem.name)")
//        } else {
//            NSLog("Did tap a normal marker")
//        }
//        return false
//    }
}
