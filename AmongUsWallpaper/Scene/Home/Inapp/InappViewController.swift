//
//  InappViewController.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 11/8/20.
//

import UIKit
import StoreKit

class InappViewController: UIViewController, StoryboardInstantiatable {
    
    static var storyboardName: AppStoryboard = .inapp
    var products: [SKProduct] = []

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var contentPriceView: RoundUIView!
    @IBOutlet weak var continueButton: RoundUIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        if products.first?.localizedTitle.isEmpty == true {
            titleLabel.text = "Unlimited Feature"
        } else {
            titleLabel.text = products.first?.localizedTitle
        }
        
        if let price = products.first?.localizedPrice {
            priceLabel.text = price
        }
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseFailNotification(_:)), name: .IAPHelperPurchaseFailNotification, object: nil)
    }
    
    func buyInapp() {
        if let product = self.products.filter({$0.productIdentifier == InappId.buyOne.rawValue}).first {
            AmongUsProduct.store.buyProduct(product)
        }
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else {return}
        
        print(productID)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePurchaseFailNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else {return}
        
        print(productID)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func restoreButtonDidTAp(_ sender: Any) {
        AmongUsProduct.store.restorePurchases()
    }
    
    @IBAction func termUseButtonDidTap(_ sender: Any) {
        let termUseVC = TermOfUseVC.instantiate()
        self.navigationController?.pushViewController(termUseVC, animated: true)
    }
    
    @IBAction func privacyButtonDidTap(_ sender: Any) {
        let privacyVC = PrivacyVC.instantiate()
        self.navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func continueButtonDidTap(_ sender: Any) {
        buyInapp()
    }
    
    @IBAction func notNowButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
