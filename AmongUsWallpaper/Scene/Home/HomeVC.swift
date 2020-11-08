//
//  HomeVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit
import GoogleMobileAds

protocol TabbarDelegate: class {
    func didTapEditButton()
}

class HomeVC: UIViewController, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .home
    
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    weak var delegate: TabbarDelegate?
    
    var discoverVC: UIViewController!
    var myWallpaperVC: UIViewController!
    var settingVC: UIViewController!
    var viewControllers: [UIViewController]!
    var selectedIndex: Int = 0
    
    var currentStatusForEditButton: Bool = false
    
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
            editButton.isHidden = true
        case 1:
            titleLabel.text = "My Wallpaper"
            editButton.isHidden = false
        case 2:
            titleLabel.text = "Setting"
            editButton.isHidden = true
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
    
    @IBAction func editButtonDidTap(_ sender: Any) {
        NotificationCenter.default.post(name: .didEditMyWallpaper, object: nil)
    }
    
    @objc func goToAUScreen() {
        PushVC.shared.goToAmongUs(nav: self.navigationController)
    }
}
