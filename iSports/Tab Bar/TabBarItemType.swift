//
//  TabBarItemType.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import UIKit

enum TabBarItemType {
    
    // MARK: Case
    
    case map, home, my
    
}

// MARK: - Title

extension TabBarItemType {
    
    var title: String {
        
        switch self {
            
        case .home:
            
            return NSLocalizedString("Home", comment: "")
            
        case .map:
            
            return NSLocalizedString("Map", comment: "")
            
        case .my:
            
            return NSLocalizedString("my", comment: "")
                        
        }
        
    }
    
}

// MARK: - Image

extension TabBarItemType {
    
    var image: UIImage {
        
        switch self {
            
        case .home:
            
            return #imageLiteral(resourceName: "icon-home").withRenderingMode(.alwaysTemplate)
            
        case .map:
            
            return #imageLiteral(resourceName: "icon-map").withRenderingMode(.alwaysTemplate)
            
        case .my:
            
            return #imageLiteral(resourceName: "icon-my").withRenderingMode(.alwaysTemplate)
            
        }
        
    }
    
}
