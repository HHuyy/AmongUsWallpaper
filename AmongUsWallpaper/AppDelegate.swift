//
//  AppDelegate.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit
import Firebase
import IQKeyboardManager
import RealmSwift
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        configRootVC()
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldShowToolbarPlaceholder = false
        let realm = try! Realm()
        print("Realm is located at:", realm.configuration.fileURL!)
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        return true
    }

    func configRootVC() {
        let homeVC = HomeVC.instantiate()
        let navigation = BaseNavigation(rootViewController: homeVC)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
}

