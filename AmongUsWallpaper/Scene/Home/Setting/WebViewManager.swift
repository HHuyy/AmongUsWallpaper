//
//  WebViewManager.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/2/20.
//

import WebKit

class WebViewManager {
    public static let shared = WebViewManager()
    
    private init () {
        
    }
    
    func openPrivacy(_ webView: WKWebView) {
        let url = URL(string: "https://sites.google.com/view/among-uslivewallpaper/privacy-policy")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func openTermOfUse(_ webView: WKWebView) {
        let url = URL(string: "https://sites.google.com/view/among-uslivewallpaper/terms-and-condition?authuser=0")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func openContactUs(_ webView: WKWebView) {
        let url = URL(string: "https://sites.google.com/view/among-uslivewallpaper/support?authuser=0")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
}
