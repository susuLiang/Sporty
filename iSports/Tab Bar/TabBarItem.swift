//
//  TabBarItem.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import UIKit

class TabBarItem: UITabBarItem {
    
    // MARK: Property
    
    var itemType: TabBarItemType?
    
    // MARK: Init
    
    init(itemType: TabBarItemType) {
        
        super.init()
        
        self.itemType = itemType
        
        self.title = itemType.title
        
        self.image = itemType.image
                
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
}
