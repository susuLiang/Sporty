//
//  TabBarController.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import Foundation
import UIKit


class TabBarController: UITabBarController {
    
    // MARK: Init
    
    init(itemTypes: [TabBarItemType]) {
        
        super.init(nibName: nil, bundle: nil)
        
        let viewControllers: [UIViewController] = itemTypes.map(
            TabBarController.prepare
        )
        
        setViewControllers(viewControllers, animated: false)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTabBar()
        
    }
    
    // MARK: Set Up
    
    private func setUpTabBar() {
        
        tabBar.barStyle = .default
        
        tabBar.isTranslucent = false
        
        // Todo: palette
        tabBar.tintColor = UIColor(
            red: 53.0 / 255.0,
            green: 184.0 / 255.0,
            blue: 208 / 255.0,
            alpha: 1.0
        )
        
    }
    
    // MARK: Prepare Item Type
    
    static func prepare(for itemType: TabBarItemType) -> UIViewController {
        
        switch itemType {
            
        case .map:

            let profileTableViewController = MapController()

            let navigationController = UINavigationController(
                rootViewController: profileTableViewController
            )
            
            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )
            
            return navigationController
            
        case .home:
            
            let listsController = ListsController()
            
            let navigationController = UINavigationController(
                rootViewController: listsController
            )
            
            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )
                                                
            return navigationController
            
        case .messages:
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let cartTableViewController = storyboard.instantiateViewController(withIdentifier: "Main")

            let navigationController = UINavigationController(
                rootViewController: cartTableViewController
            )

            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )
            
            return navigationController
            
        }
        
    }
}
