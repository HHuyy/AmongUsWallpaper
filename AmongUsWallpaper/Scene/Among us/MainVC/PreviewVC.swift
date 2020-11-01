//
//  PreviewVC.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 10/30/20.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class PreviewVC: UIViewController, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .preview
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet var playerView: PlayerView!
    
    var videoCompostion: AVVideoComposition!
    var compostion: AVComposition!
    
    private var interstitialAd: GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.setupPlayerItem(asset: compostion, videoComposition: videoCompostion)
        self.playerView.delegate = self
        setupFullscreenAd()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    @IBAction func downloadButtonDidTap(_ sender: Any) {
        showAd()
    }
    @IBAction func backButtonDidTap(_ sender: Any) {
    }
    @IBAction func moreButtonDidTap(_ sender: Any) {
    }   
}

extension PreviewVC: PlayerViewDelegate {
    func playerView(_ view: PlayerView, isReadyToPlay: Bool) {
        if isReadyToPlay {
            view.player?.play()
        }
    }
}

extension PreviewVC: GADInterstitialDelegate {
    func setupFullscreenAd() {
        self.interstitialAd = createAndLoadInterstitial()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
//        var interstitial = GADInterstitial(adUnitID: Constant.fullscreenId)
          var interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func showAd() {
        if interstitialAd!.isReady {
            interstitialAd!.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        // download here
        self.interstitialAd = createAndLoadInterstitial()
    }
}
