//
//  PreviewVC.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 10/30/20.
//

import UIKit
import AVFoundation

class PreviewVC: UIViewController, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .preview
    

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet var playerView: PlayerView!
    
    var videoCompostion: AVVideoComposition!
    var compostion: AVComposition!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.setupPlayerItem(asset: compostion, videoComposition: videoCompostion)
        self.playerView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    @IBAction func downloadButtonDidTap(_ sender: Any) {
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
