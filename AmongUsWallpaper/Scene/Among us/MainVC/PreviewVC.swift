//
//  PreviewVC.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 10/30/20.
//

import UIKit
import AVFoundation
import Photos
import PhotosUI
import AVFoundation
import AVKit

class PreviewVC: UIViewController, StoryboardInstantiatable, PHLivePhotoViewDelegate {
    static var storyboardName: AppStoryboard = .preview
    
    @IBOutlet weak var livePhotoView: PHLivePhotoView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet var playerView: PlayerView!
    
    //demo
    @IBOutlet weak var videoView: UIView!
    
    var videoCompostion: AVVideoComposition!
    var compostion: AVComposition!
    var livePhotoBadgeLayer = CALayer()
    var playerController: AVPlayerViewController?
    var pickedURL: URL?
    
    //demo
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.setupPlayerItem(asset: compostion, videoComposition: videoCompostion)
        livePhotoView.contentMode = .scaleAspectFit
        livePhotoView.delegate = self
        self.playerView.delegate = self
        
        let livePhotoBadge = PHLivePhotoView.livePhotoBadgeImage(options: .overContent)
        
        guard let livePhotoBadgeImage = livePhotoBadge.cgImage else {
            return
        }
        
        self.livePhotoBadgeLayer.frame = livePhotoView.bounds
        self.livePhotoBadgeLayer.contentsGravity = CALayerContentsGravity.topLeft
        self.livePhotoBadgeLayer.isGeometryFlipped = true
        self.livePhotoBadgeLayer.contentsScale = UIScreen.main.scale
        
        self.livePhotoBadgeLayer.contents = livePhotoBadgeImage
        livePhotoView.layer.addSublayer(self.livePhotoBadgeLayer)
        
//        playerController = AVPlayerViewController()
//        if let playerView = playerController?.view {
//            self.view.addSubview(playerView)
//        }
        
        
        //demo
        player = AVPlayer(url: pickedURL!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.livePhotoView.livePhoto != nil {
            self.livePhotoView.startPlayback(with: .hint)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { () -> Void in
                self.livePhotoView.stopPlayback()
            }
        }
        
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()
        
        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
        }
            
        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
        }
            
        else if (status == PHAuthorizationStatus.notDetermined) {
            
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    
                }
                    
                else {
                    
                }
            })
        }
            
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
    }
    
    @IBAction func downloadButtonDidTap(_ sender: Any) {
    }
    @IBAction func backButtonDidTap(_ sender: Any) {
    }
    @IBAction func moreButtonDidTap(_ sender: Any) {
    }
    
    func livePhotoDemo() {
        let urlPath = Bundle.main.url(forResource: "8", withExtension: "pdf")

            LivePhoto.generate(from: urlPath, videoURL: pickedURL!) { (percent) in
//                DispatchQueue.main.async {
//                    self.progressView.progress = Float(percent)
//                }
            } completion: { (livePhoto, resources) in
//                self.livePhotoView.livePhoto = livePhoto
                if let resources = resources {
                    LivePhoto.saveToLibrary(resources, completion: { (success) in
                        if success {
//                            self.postAlert("Live Photo Saved", message:"The live photo was successfully saved to Photos.")
                        }
                        else {
//                            self.postAlert("Live Photo Not Saved", message:"The live photo was not saved to Photos.")
                        }
                    })
                }
            }

    }
    
    // MARK: PHLivePhotoViewDelegate
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, willBeginPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.livePhotoBadgeLayer.opacity = 0.0
    }
    
    func livePhotoView(_ livePhotoView: PHLivePhotoView, didEndPlaybackWith playbackStyle: PHLivePhotoViewPlaybackStyle) {
        self.livePhotoBadgeLayer.opacity = 1.0
    }

}

extension PreviewVC: PlayerViewDelegate {
    func playerView(_ view: PlayerView, isReadyToPlay: Bool) {
        if isReadyToPlay {
            view.player?.play()
        }
    }
}
