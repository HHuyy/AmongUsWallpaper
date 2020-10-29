//
//  AmongUsMainVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

class AmongUsMainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        print("++++++++++++++++")
        PushVC.shared.goToHome(nav: self.navigationController)
    }
    
}
