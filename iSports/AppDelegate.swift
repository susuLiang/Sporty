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
import IQKeyboardManagerSwift
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        Fabric.sharedSDK().debug = true

        let key = GoogleMapKey.init()

        GMSServices.provideAPIKey(key.mapKey)
        GMSPlacesClient.provideAPIKey(key.mapKey)

        IQKeyboardManager.sharedManager().enable = true

        // swiftlint:disable force_cast
        let gifViewController = UINib.load(nibName: "GifViewController") as! GifViewController
        // swiftlint:enable force_cast

        let rootViewController = gifViewController

        let window = UIWindow(frame: UIScreen.main.bounds)

        window.rootViewController = rootViewController

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

//    func makeEntryController() -> UIViewController {
//        if Auth.auth().currentUser?.uid == nil {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let loginController = storyboard.instantiateViewController(withIdentifier: "loginController")
//            return loginController
//        } else {
//            let tabBarController = TabBarController(itemTypes: [ .home, .map, .my, .setting])
//            tabBarController.selectedIndex = 0
//            return tabBarController
//        }
//    }
}
