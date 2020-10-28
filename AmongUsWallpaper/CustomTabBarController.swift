//
//  CustomTabBarController.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import Foundation
import UIKit

class CustomTabBarController:  UITabBarController, UITabBarControllerDelegate {
    var homeViewController: HomeVC!
//    var secondViewController: SecondViewController!
//    var actionViewController: actionViewController!
//    var thirdViewController: ThirdViewController!
//    var fourthViewController: FourthViewController!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.delegate = self
        
        homeViewController = HomeVC()
//        secondViewController = SecondViewController()
//        actionViewController = ActionViewController()
//        thirdViewController = ThirdViewController()
//        fourthViewController = FourthViewController()
        homeViewController.tabBarItem.image = UIImage(named: "home")
        homeViewController.tabBarItem.selectedImage = UIImage(named: "home-selected")
        
        for tabBarItem in tabBar.items! {
            
//            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }
    
    
}
