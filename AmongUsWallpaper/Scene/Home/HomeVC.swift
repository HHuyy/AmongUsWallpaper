//
//  HomeVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

class HomeVC: UIViewController {
    
    @IBOutlet var tabButtons: [UIButton]!
    
    var discoverVC: UIViewController!
    var myWallpaperVC: UIViewController!
    var settingVC: UIViewController!
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        let dicoverSB = UIStoryboard(name: "Dicover", bundle: nil)
        let myWallpaperSB = UIStoryboard(name: "MyWallpaper", bundle: nil)
        let settingSB = UIStoryboard(name: "Setting", bundle: nil)
        discoverVC = dicoverSB.instantiateInitialViewController()
        myWallpaperVC = myWallpaperSB.instantiateInitialViewController()
        settingVC = settingSB.instantiateInitialViewController()
        viewControllers = [discoverVC, myWallpaperVC, settingVC]
    }
    
    
}
