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
    
    let type: String
    
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

enum Level: String {
    
    case A, B, C, D
    
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
    
    var id: String
    
    var type: String
    
    var level: Level?
    
    var city: String
    
    var time: String
    
}
