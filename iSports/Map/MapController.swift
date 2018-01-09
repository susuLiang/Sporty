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

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?

    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), camera: GMSCameraPosition.camera(withLatitude: 25.0472, longitude: 121.564939, zoom: 12.0))

    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 14.0
    var selectedPlace: GMSPlace?

    var results: [Activity] = []

    var selectedType: String? {
        didSet {
            self.mapView.clear()
            var selected: [Activity] = []
            for result in results where result.type == selectedType {
                selected.append(result)
            }
            self.setMarker(activities: selected)
        }
    }

    let searchView = MapSearchController()

    var isShowed = false

    var detailView: MapDetailController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setLocationManager()
        setNavigationBar()
        getLocation()
        setSearchBar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setSearchBar() {
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        let subView = UIView(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, width: 350.0, height: 45.0))

        subView.addSubview((searchController?.searchBar)!)
        view.addSubview(subView)
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = false

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
    }

    func setMapView() {
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: UIScreen.main.bounds.height)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(mapView)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }

    @objc func search() {
        searchView.mainViewController = self
        searchView.view.frame = CGRect(x: UIScreen.main.bounds.width - 150, y: (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height, width: 150, height: UIScreen.main.bounds.height)

        if !isShowed {
            self.addChildViewController(searchView)
            self.view.addSubview(searchView.view)
            searchView.didMove(toParentViewController: self)
            isShowed = true
        } else {
            searchView.willMove(toParentViewController: nil)
            searchView.view.removeFromSuperview()
            searchView.removeFromParentViewController()
            self.getLocation()
            isShowed = false
        }
    }

    func setLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.distanceFilter = 50
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        self.placesClient = GMSPlacesClient.shared()
    }

    func setNavigationBar() {
        navigationItem.title = NSLocalizedString("Map", comment: "")
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-search"), style: .plain, target: self, action: #selector(search))
        navigationItem.rightBarButtonItems = [searchButton]
        navigationController?.navigationBar.tintColor = .white
    }

}

extension MapController {

    func getLocation() {

        FirebaseProvider.shared.getData(completion: { (results, error) in

            if error == nil {

                self.results = results!

                self.setMarker(activities: self.results)

            }
        })
    }

    func setMarker(activities: [Activity]) {

        for court in activities {

            var iconName: String = ""

            let marker = GMSMarker()

            marker.position = CLLocationCoordinate2D(
                latitude: Double(court.place.placeLatitude)!,
                longitude: Double(court.place.placeLongitude)!
            )

            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
            marker.title = court.id

            switch court.type {
            case "羽球": iconName = "badmintonMarker"
            case "棒球": iconName = "baseballMarker"
            case "籃球": iconName = "basketballMarker"
            case "排球": iconName = "volleyballMarker"
            case "網球": iconName = "tennisMarker"
            case "足球": iconName = "soccerMarker"
            default: break
            }

            let iconImage = UIImageView()
            iconImage.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
            iconImage.image = UIImage(named: iconName)
            iconImage.contentMode = .center
            iconImage.layer.shadowColor = UIColor.black.cgColor
            iconImage.layer.shadowRadius = 0.5
            iconImage.layer.shadowOffset = CGSize(width: 0, height: 0)
            iconImage.layer.shadowOpacity = 1

            let backView = UIView()
            backView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
            backView.backgroundColor = .clear
            backView.addSubview(iconImage)

            backView.layer.cornerRadius = 10
            backView.layer.shadowOpacity = 0.5
            backView.layer.shadowRadius = 0.5
            backView.clipsToBounds = true

            marker.iconView = backView

//            marker.icon = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
            marker.map = mapView

        }
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var selectedActivity: Activity?

        for activity in results where activity.id == marker.title {
            selectedActivity = activity
            break
        }

        let detailView = MapDetailController()
        self.detailView = detailView
        detailView.selectedPlace = selectedActivity?.place
        detailView.mainViewController = self

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

    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                              longitude: place.coordinate.longitude,
                                              zoom: zoomLevel)

        mapView.camera = camera
    }

    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
