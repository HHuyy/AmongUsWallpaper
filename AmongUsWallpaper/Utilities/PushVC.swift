//
//  PushVC.swift
//  AmongUsWallpaper
//
//  Created by Brite Solutions on 10/29/20.
//

import Foundation
import UIKit

class PushVC: NSObject {
    
    static let shared = PushVC()
    
    func goToHome(nav: UINavigationController?) {
        let sb = UIStoryboard(name: "Home", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? HomeVC {
            nav?.pushViewController(vc, animated: true)
        }
    }
    
    func goToAmongUs(nav: UINavigationController?) {
        let sb = UIStoryboard(name: "AmongUsMain", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? AmongUsMainVC {
            nav?.pushViewController(vc, animated: true)
        }
    }
}
