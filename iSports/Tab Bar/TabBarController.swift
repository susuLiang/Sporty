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
        self.selectedIndex = 0

    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        for (key, value) in (tabBar.items?.enumerated())! {
            
            if value == item {
                animation(withIndex: key)
            }
            
        }
    }
    
    func animation(withIndex index: Int) {
        
        var tabBarButtonArray: [Any] = []
        
        for tabBarButton in self.tabBar.subviews {
            if tabBarButton.isKind(of: NSClassFromString("UITabBarButton")!) {
                tabBarButtonArray.append(tabBarButton)
            }
        }
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.2, 0.9, 1.02, 1.0]
        animation.duration = TimeInterval(0.5)
        animation.calculationMode = CAAnimationCalculationMode.cubic
        
        let tabBarLayer = (tabBarButtonArray[index] as AnyObject).layer
        tabBarLayer?.add(animation, forKey: "animtaion")
    }

    // MARK: Set Up

    private func setUpTabBar() {

        tabBar.barStyle = .default

        tabBar.isTranslucent = false

        // Todo: palette
        tabBar.tintColor = mySkyBlue

        tabBar.barTintColor = .white

    }

    // MARK: Prepare Item Type

    static func prepare(for itemType: TabBarItemType) -> UIViewController {

        switch itemType {

        case .map:

            let profileTableViewController = MapController()

            let navigationController = BlueNavigationController(
                rootViewController: profileTableViewController
            )

            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )

            return navigationController

        case .home:

            let listsController = ListsController()

            let navigationController = BlueNavigationController(
                rootViewController: listsController
            )

            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )

            return navigationController

        case .my:

            let myActivitiesController = MyActivitiesController()

            let navigationController = BlueNavigationController(
                rootViewController: myActivitiesController
            )

            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )

            return navigationController

        case .setting:

            guard let myProfileController = UINib.load(nibName: "MyProfileController") as? MyProfileController else {
                fatalError("Can not found MyProfileController")
            }
            let navigationController = BlueNavigationController(
                rootViewController: myProfileController
            )
            navigationController.tabBarItem = TabBarItem(
                itemType: itemType
            )
            return navigationController
        }

    }
}
