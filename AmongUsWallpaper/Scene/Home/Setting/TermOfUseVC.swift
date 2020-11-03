//
//  TermOfUseVC.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/2/20.
//

import UIKit
import WebKit

class TermOfUseVC: UIViewController, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .setting
    @IBOutlet weak var contentView: UIView!
    
    var webView: WKWebView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        contentView.addSubview(webView)
        webView.fitSuperviewConstraint()
        WebViewManager.shared.openTermOfUse(self.webView)
        if let homeVC = self.navigationController?.viewControllers.first as? HomeVC {
            homeVC.titleLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let homeVC = self.navigationController?.viewControllers.first as? HomeVC {
            homeVC.titleLabel.isHidden = false
        }
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

