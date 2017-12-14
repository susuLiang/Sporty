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
        snooker,
        tennis,
        bowling
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
