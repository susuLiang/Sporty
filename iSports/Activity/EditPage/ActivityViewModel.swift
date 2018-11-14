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
        case .name: return NSLocalizedString("NAME", comment: "")
        case .type: return NSLocalizedString("TYPE", comment: "")
        case .city: return NSLocalizedString("CITY", comment: "")
        case .level: return NSLocalizedString("LEVEL", comment: "")
        case .fee: return NSLocalizedString("FEE", comment: "")
        case .time: return NSLocalizedString("TIME", comment: "")
        case .number: return NSLocalizedString("NUMBER", comment: "")
        case .allNumber: return NSLocalizedString("ALLNUMBER", comment: "")
        case .court: return NSLocalizedString("COURT", comment: "")
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
    var courts: [Court] = []
    
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
    var placesClient: GMSPlacesClient!
}
