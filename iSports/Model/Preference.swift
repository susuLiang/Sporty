//
//  Preference.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

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

let type: [Sportstype: String] = [
    .baseball: "棒球",
    .basketball: "籃球",
    .volleyball: "排球",
    .badminton: "羽球",
    .tennis: "網球",
    .football: "足球"]

struct Preference {
    
    var id: String
    
    var type: Sportstype
    
    var level: Level
    
    var place: String
    
    var time: String
    
}
