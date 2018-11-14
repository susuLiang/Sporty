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

struct Activity {
    
    var id: String = ""
    var name: String = ""
    var level: String = ""
    var place: Place!
    var address: String = ""
    var time: String = ""
    var type: String = ""
    var number: Int = -1
    var allNumber: Int = -1
    var fee: Int = -1
    var author: String = ""
    var authorUid: String = ""
    var postedTime: String = ""
    var city: String = ""

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
            let author = data["author"] as? String,
            let postedTime = data["postedTime"] as? String
            else { throw JSONError.jsonError }
        
        if let city = data["city"] as? String {
            self.city = city
        }

        self.name = name
        self.type = type
        self.time = time
        self.place = Place(placeName: placeName, placeLatitude: latitude, placeLongitude: longitude)
        self.level = level
        self.address = address
        self.number = number
        self.allNumber = allNumber
        self.fee = fee
        self.authorUid = userUid
        self.author = author
        self.postedTime = postedTime
    }
    
    init(id: String = "", name: String = "", level: String = "", place: Place! = nil, address: String = "", time: String = "", type: String = "", number: Int = -1, allNumber: Int = -1, fee: Int = -1, author: String = "", authorUid: String = "", postedTime: String = "", city: String = "") {
        self.id = id
        self.name = name
        self.type = type
        self.time = time
        self.place = place
        self.level = level
        self.address = address
        self.number = number
        self.allNumber = allNumber
        self.fee = fee
        self.authorUid = authorUid
        self.author = author
        self.postedTime = postedTime
        self.city = city
    }

}

enum Sportstype: String {
    case basketball
    case volleyball
    case baseball
    case football
    case badminton
    case tennis
    
    static var count: Int { return Sportstype.tennis.hashValue + 1}
}

let levelArray = ["A", "B", "C", "D"]
let cityArray: [String] = ["臺北市", "新北市", "基隆市", "桃園市", "新竹市", "新竹縣", "苗栗縣", "臺中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", "嘉義縣", "臺南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", "臺東縣", "澎湖縣", "金門縣" ]
let typeArray: [String] = ["棒球", "籃球", "排球", "羽球", "網球", "足球"]
let time = ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期日"]
let hour = Array(1...24).map { $0.string }
let minute = (00...11).map { $0 * 5}.map { $0.string }

struct Preference {

    var type: String
    var level: String?
    var place: String
    var time: String

}

struct Message {
    
    var message: String
    var date: String
    var userUid: String
    
}
