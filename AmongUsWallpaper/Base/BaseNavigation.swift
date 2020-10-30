//
//  BaseNavigation.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 10/30/20.
//

import UIKit

class BaseNavigation: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationBar.isHidden = true
        self.interactivePopGestureRecognizer?.isEnabled = false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        var defaltStyle: UIStatusBarStyle
        if #available(iOS 13.0, *) {
            defaltStyle = .lightContent
        } else {
            defaltStyle = .default
        }
        
        return defaltStyle
    }
}
