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
        clearTempDirectory()
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
//        let homeVC = PreviewVC.instantiate()
        let navigation = BaseNavigation(rootViewController: homeVC)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
    
    func clearTempDirectory() {
//        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: NSTemporaryDirectory()) else {
//            return
//        }
//
//        contents.forEach { (path) in
//            try? FileManager.default.removeItem(atPath: "\(NSTemporaryDirectory())\(path)")
//        }
        
        FileManager.createWallpaperDirIfNeeded()
    }
}
