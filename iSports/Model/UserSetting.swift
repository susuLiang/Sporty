//
//  User.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/20.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

struct UserSetting {
    
    var name: String
    
    var preference: Preference
    
    init(name: String, preference: Preference) {
        self.name = name
        self.preference = preference
        
    }
    
}
