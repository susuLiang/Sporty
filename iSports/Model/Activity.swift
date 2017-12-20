//
//  Activity.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/15.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

struct Activity {
    
    let id: String
    
    let name: String
    
    let level: Level
    
    let place: Place
    
    let address: String
    
    let time: String
    
    let type: Sportstype
    
    let number: Int
    
    let allNumber: Int
    
    let fee: Int
    
    let author: String

    let authorUid: String
    
}

struct Place {
    
    let placeName: String
    
    let placeLatitude: String
    
    let placeLongitude: String

}
