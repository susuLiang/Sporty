//
//  Preference.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/14.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

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

struct Preference {
    
    var id: String
    
    var type: Sportstype
    
    var level: Level
    
    var place: String
    
    var time: String
    
}
