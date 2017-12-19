//
//  CourtsModel.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/18.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

struct Court {
    
    var courtID: Int
    var name: String
    var tel: String?
    var address: String
    var rateCount: Int
    var gymFuncList: String
    var latitude: String
    var longitude: String
    
    init(courtID: Int, name: String, tel: String?,
         address: String, rateCount: Int,
         gymFuncList: String, latitude: String, longitude: String) {
        
        self.courtID = courtID
        self.name = name
        self.tel = tel
        self.address = address
        self.rateCount = rateCount
        self.gymFuncList = gymFuncList
        self.latitude = latitude
        self.longitude = longitude
    }
}

