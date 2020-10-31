//
//  HomeVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit
import GoogleMobileAds

class HomeVC: UIViewController, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .home
    
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(goToAUScreen), name: .goToAU, object: nil)
        let dicoverSB = UIStoryboard(name: "Discover", bundle: nil)
        let myWallpaperSB = UIStoryboard(name: "MyWallpaper", bundle: nil)
        let settingSB = UIStoryboard(name: "Setting", bundle: nil)
        discoverVC = dicoverSB.instantiateInitialViewController()
        myWallpaperVC = myWallpaperSB.instantiateInitialViewController()
        settingVC = settingSB.instantiateInitialViewController()
        viewControllers = [discoverVC, myWallpaperVC, settingVC]
        tabButtons[selectedIndex].isSelected = true
        didPressTab(tabButtons[selectedIndex])
    }
    
    @IBAction func didPressTab(_ sender: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = sender.tag
        tabButtons[previousIndex].isSelected = false
        
        switch selectedIndex {
        case 0:
            titleLabel.text = "Discover"
        case 1:
            titleLabel.text = "My Wallpaper"
        case 2:
            titleLabel.text = "Setting"
        default:
            break
        }
        
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
        
        sender.isSelected = true
        let vc = viewControllers[selectedIndex]
        addChild(vc) //Calls the viewWillAppear method of the vc
        vc.view.frame = contentView.bounds
        contentView.addSubview(vc.view)
        vc.didMove(toParent: self) //Call the viewDidAppear method of the vc
    }
    
    
    @objc func goToAUScreen() {
        PushVC.shared.goToAmongUs(nav: self.navigationController)
    }
}
