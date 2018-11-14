//
//  ActivityViewModel.swift
//  iSports
//
//  Created by Shu Wei Liang on 2018/11/13.
//  Copyright © 2018 Susu Liang. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

enum ActivityCellType: Int {
    case name
    case type
    case city
    case level
    case fee
    case time
    case number
    case allNumber
    case court
    case map
    case button
    
    static let count = 11
    
    var description: String {
        switch self {
        case .name: return "NAME"
        case .type: return "TYPE"
        case .city: return "CITY"
        case .level: return "LEVEL"
        case .fee: return "FEE"
        case .time: return "TIME"
        case .number: return "NUMBER"
        case .allNumber: return "ALLNUMBER"
        case .court: return "COURT"
        case .map, .button: return ""
        }
    }
    
    var data: [String] {
        switch self {
        case .name, .fee, .time, .number, .allNumber, .map, .button, .court: return []
        case .type: return typeArray
        case .city: return cityArray
        case .level: return levelArray
        }
    }
}

enum ActivityViewType {
    case add
    case edit
}

class ActivityViewModel {
    
    var viewType: ActivityViewType = .add
    var cells: [UITableViewCell] = []
    var courts: [Court]? {
        didSet {
            //            courtPicker.reloadAllComponents()
        }
    }
    
    var myPost: Activity? {
        didSet {
//            if let myPost = myPost {
//                setText(myPost)
//                mapPlacedView.isHidden = true
//                //                cityLabel.text = NSLocalizedString("ADDRESS", comment: "")
//                navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon-save"), style: .plain, target: self, action: #selector(showSaveAlert))
//                cancelButton.isHidden = true
//                addButton.isHidden = true
//                
//            }
        }
    }
    
    var thisPost: Activity = Activity() {
        didSet {
            if !thisPost.type.isEmpty {
                typeChanged = true
            }
        }
    }
    
    var didSelectedCity: String = "" {
        didSet {
            if !didSelectedCity.isEmpty {
                cityChanged = true
            }
        }
    }
    
    var typeChanged: Bool = false
    var cityChanged: Bool = false
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
//    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
//    var zoomLevel: Float = 15.0
//    var selectedPlace: GMSPlace?
}
