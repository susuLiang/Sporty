//
//  AppDelegateExtensions.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/29.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation

extension AppDelegate {
    
    // swiftlint:disable force_cast
    class var shared: AppDelegate {
        
        return UIApplication.shared.delegate as! AppDelegate
        
    }
    // swiftlint:enable force_cast
    
}
