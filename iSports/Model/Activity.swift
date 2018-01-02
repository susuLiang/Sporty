//
//  Activity.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/15.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

enum JSONError: Error {
    
    case jsonError
    
    case userSettingJsonError
}

struct Place {
    
    var placeName: String
    
    var placeLatitude: String
    
    var placeLongitude: String
    
}


enum Level: String {
    case A, B, C, D
}

struct Activity {
    
    let id: String
    
    let name: String
    
    var level: Level
    
    var place: Place
    
    let address: String
    
    let time: String
    
    let type: String
    
    let number: Int
    
    let allNumber: Int
    
    let fee: Int
    
    let author: String

    let authorUid: String
    
    init(_ json: Any, id: String) throws {
        
        place = Place(placeName: "", placeLatitude: "", placeLongitude: "")
        
        guard let data = json as? [String: AnyObject] else { throw JSONError.jsonError}
            
        self.id = id
            
        guard let name = data["name"] as? String,
            let type = data["type"] as? String,
            let time = data["time"] as? String,
            let placeName = data["place"] as? String,
            let latitude = data["latitude"] as? String,
            let longitude = data["longitude"] as? String,
            let level = data["level"] as? String,
            let address = data["address"] as? String,
            let number = data["number"] as? Int,
            let allNumber = data["allNumber"] as? Int,
            let fee = data["fee"] as? Int,
            let userUid = data["userUid"] as? String,
            let author = data["author"] as? String else { throw JSONError.jsonError }
    
        self.name = name
        self.type = type
        self.time = time
        self.place = Place(placeName: placeName, placeLatitude: latitude, placeLongitude: longitude)
        self.level = Level(rawValue: level)!
        self.address = address
        self.number = number
        self.allNumber = allNumber
        self.fee = fee
        self.authorUid = userUid
        self.author = author
    }

}

let levelArray = ["A", "B", "C", "D"]

let city: [String] = ["臺北市", "新北市", "基隆市", "桃園市", "新竹市", "新竹縣", "苗栗縣", "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "臺南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣" ]

enum Sportstype: String {
    case
    basketball,
    volleyball,
    baseball,
    football,
    badminton,
    tennis

    static var count: Int { return Sportstype.tennis.hashValue + 1}
}

let typeDict: [Sportstype: String] = [
    .baseball: "棒球",
    .basketball: "籃球",
    .volleyball: "排球",
    .badminton: "羽球",
    .tennis: "網球",
    .football: "足球"]

let typeArray: [String] = ["棒球", "籃球", "排球", "羽球", "網球", "足球"]

let time = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]

struct Preference {
    
    var type: String
    
    var level: Level?
    
    var place: String
    
    var time: String
    
}
