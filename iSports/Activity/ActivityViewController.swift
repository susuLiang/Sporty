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
            cell.delegate = self
            return cell
            
        case .type, .city, .level:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            cell.addPickerView(data: [type.data], components: 1, numberOfRows: [type.data.count + 1])
            cell.delegate = self
            return cell

        case .time:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            cell.addPickerView(data: [time, hour, minute], components: 3, numberOfRows: [time.count + 1, hour.count + 1, minute.count + 1])
            cell.type = type.description
            cell.delegate = self
            return cell

        case .court:
            let cell = tableView.dequeueReusableCell(withClass: ActivityBasicTableViewCell.self)!
            cell.configCell(title: type.description)
            if let courts = activityViewModel.courts {
                cell.textField.text = ""
                cell.textField.isEnabled = true
                cell.addPickerView(data: [courts.map { $0.name }], components: 1, numberOfRows: [courts.count + 1])
            } else {
                cell.textField.text = NSLocalizedString("Please choose the TYPE and CITY first.", comment: "")
                cell.textField.isEnabled = false
            }
            cell.delegate = self
            cell.type = type.description
            return cell

        case .map:
            let cell = tableView.dequeueReusableCell(withClass: ActivityMapTableViewCell.self)!
            if let place = activityViewModel.thisPost.place {
                cell.mapImageView.isHidden = false
                cell.mapImageView.addSubview(setMap(on: cell.mapImageView,
                                                    latitude: Double(place.placeLatitude) ?? 0.0,
                                                    longitude: Double(place.placeLongitude) ?? 0.0))
            } else {
                cell.mapImageView.isHidden = true
            }
            return cell

        case .button:
            let cell = tableView.dequeueReusableCell(withClass: ActivityButtonTableViewCell.self)!
            cell.delegate = self
            return cell
            
        }
    }
    
    func getLocation(city: String, gym: String) {
        LoadingIndicator.shared.start()
        if let city = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let gym = gym.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            CourtsProvider.shared.getApiData(city: city, gymType: gym, completion: { (courts, error) in
                if error == nil {
                    self.activityViewModel.courts = courts!
                    DispatchQueue.main.async {
                        self.activityViewModel.cells[ActivityCellType.court.rawValue] = self.createCellByType(type: .court)
                        self.tableView.reloadRows(at: [IndexPath(row: ActivityCellType.court.rawValue, section: 0)], with: .automatic)
                    }
                } else {
                    // todo: error handling
                }
                LoadingIndicator.shared.stop()
            })
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
    
    func setMap(on imageView: UIImageView, latitude: Double, longitude: Double) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15.0)
        let frame = CGRect(x: 0, y: 0, width: SwifterSwift.screenWidth - 30, height: imageView.frame.height)
        let mapView = GMSMapView.map(withFrame: frame, camera: camera)
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        
        setLocationManager()
        return mapView
    }
    
    func setLocationManager() {
        activityViewModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        activityViewModel.locationManager.requestAlwaysAuthorization()
        activityViewModel.locationManager.distanceFilter = 20
        activityViewModel.locationManager.startUpdatingLocation()
        activityViewModel.locationManager.delegate = self
        activityViewModel.placesClient = GMSPlacesClient.shared()
    }
    
}

extension ActivityViewController: ActivityButtonDelegate {
    
    func tapButton() {
    }
    
}

extension ActivityViewController: ActivityTextFieldDelegate {
    
    func pickerViewSelected(index: Int) {
        guard let courts = activityViewModel.courts else { return }
        let thisPlace = courts[index - 1]
        activityViewModel.thisPost.place = Place(placeName: thisPlace.name,
                                                placeLatitude: thisPlace.latitude,
                                                placeLongitude: thisPlace.longitude)
        DispatchQueue.main.async {
            self.activityViewModel.cells[ActivityCellType.map.rawValue] = self.createCellByType(type: .map)
            self.tableView.reloadRows(at: [IndexPath(row: ActivityCellType.map.rawValue, section: 0)], with: .automatic)
        }
    }
    
    func textFieldTextDidChange(cell: UITableViewCell, textField: UITextField) {
        guard let indexPath = tableView.indexPath(for: cell),
              let cellType = ActivityCellType(rawValue: indexPath.row),
              let text = textField.text
        else { return }
        
        switch cellType {
            
        case .name:
            activityViewModel.thisPost.name = text
            
        case .type:
            activityViewModel.thisPost.type = text
            
        case .level:
            activityViewModel.thisPost.level = text
            
        case .fee:
            activityViewModel.thisPost.fee = Int(text) ?? 0
            
        case .time:
            activityViewModel.thisPost.time = text
            
        case .number:
            activityViewModel.thisPost.number = Int(text) ?? 0
            
        case .allNumber:
            activityViewModel.thisPost.allNumber = Int(text) ?? 0
            
        case .city:
            activityViewModel.didSelectedCity = text
            
        case .map, .button, .court:
            break
        }
        
        if activityViewModel.typeChanged && activityViewModel.cityChanged {
            getLocation(city: activityViewModel.didSelectedCity, gym: activityViewModel.thisPost.type)
            activityViewModel.cityChanged = false
            activityViewModel.typeChanged = false
        }
        
    }
    
    
}
