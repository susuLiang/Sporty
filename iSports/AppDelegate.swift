//
//  AppDelegate.swift
//  iSports
//
//  Created by Susu Liang on 2017/12/13.
//  Copyright © 2017年 Susu Liang. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyDMdFZL04R9B8KTMXgcUXEMOa6PptbQBj8")
        GMSPlacesClient.provideAPIKey("AIzaSyDMdFZL04R9B8KTMXgcUXEMOa6PptbQBj8")
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = TabBarController(itemTypes: [ .map, .home, .messages])
        
        tabBarController.selectedIndex = 1
        
        window.rootViewController = tabBarController
        
        window.makeKeyAndVisible()
        
        self.window = window
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

