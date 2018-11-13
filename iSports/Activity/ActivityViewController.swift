//
//  ActivityViewController.swift
//  iSports
//
//  Created by Shu Wei Liang on 2018/11/13.
//  Copyright © 2018 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import NVActivityIndicatorView
import SCLAlertView

class ActivityViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var activityViewModel = ActivityViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(nibWithCellClass: ActivityBasicTableViewCell.self)
        tableView.register(nibWithCellClass: ActivityButtonTableViewCell.self)
        tableView.register(nibWithCellClass: ActivityMapTableViewCell.self)
        tableView.separatorStyle = .none
        
        for index in 0..<ActivityCellType.count {
            activityViewModel.cells.append(createCellByType(type: ActivityCellType(rawValue: index)!))
        }
    }
    
    func createCellByType(type: ActivityCellType) -> UITableViewCell {
        switch type {
        case .name, .fee, .number, .allNumber:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            return cell
            
        case .type, .city, .level:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            cell.addPickerView(data: [type.data], components: 1, numberOfRows: [type.data.count + 1])
            return cell

        case .time:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            cell.addPickerView(data: [time, hour, minute], components: 3, numberOfRows: [time.count + 1, hour.count + 1, minute.count + 1])
            cell.type = "time"
            return cell

        case .court:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            if let courts = activityViewModel.courts {
                cell.addPickerView(data: [courts.map { $0.name }], components: 1, numberOfRows: [courts.count + 1])
            }
            return cell

        case .map:
            let cell = tableView.dequeueReusableCell(withClass: ActivityMapTableViewCell.self)!
            
            return cell

        case .button:
            let cell = tableView.dequeueReusableCell(withClass: ActivityButtonTableViewCell.self)!
            return cell
            
        }
    }

}

extension ActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ActivityCellType.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return activityViewModel.cells[indexPath.row]
    }
    
}

extension ActivityViewController: UITableViewDelegate {
}

extension ActivityViewController: CLLocationManagerDelegate {
    
    func setMap(latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
//        let mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: courtTextField.frame.width, height: mapPlacedView.frame.height), camera: camera)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = activityViewModel.mapView
        
        setLocationManager()
        return activityViewModel.mapView
    }
    
    func setLocationManager() {
        activityViewModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        activityViewModel.locationManager.requestAlwaysAuthorization()
        activityViewModel.locationManager.distanceFilter = 50
        activityViewModel.locationManager.startUpdatingLocation()
        activityViewModel.locationManager.delegate = self
        activityViewModel.placesClient = GMSPlacesClient.shared()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        marker.map = activityViewModel.mapView
    }
}
