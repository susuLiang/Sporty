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
    
//    var description: String {
//        switch self {
//        case .basketball: return "籃球"
//        case .volleyball   : return "排球"
//        case .baseball  : return "棒球"
//        case .football : return "足球"
//        case .badminton: return "羽球"
//        case .tennis   : return "網球"
//        default: return ""
//        }
//    }
}

enum Level: String {

    case A, B, C, D

}

struct Preference {
    
    let id: String
    
    let type: Sportstype
    
    let level: Level
    
    let place: String
    
    let time: String
    
}
