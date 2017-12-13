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
    
    case map, home, messages
    
}

// MARK: - Title

extension TabBarItemType {
    
    var title: String {
        
        switch self {
            
        case .home:
            
            return NSLocalizedString("Home", comment: "")
            
        case .map:
            
            return NSLocalizedString("Map", comment: "")
            
        case .messages:
            
            return NSLocalizedString("Messages", comment: "")
                        
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
            
        case .messages:
            
            return #imageLiteral(resourceName: "icon-chat").withRenderingMode(.alwaysTemplate)
            
        }
        
    }
    
}
