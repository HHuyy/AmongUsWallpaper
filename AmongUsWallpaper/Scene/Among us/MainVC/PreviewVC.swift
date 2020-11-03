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
    // MARK: - Properties
    var amongUs: AmongUsModel?
    
    //demo
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var asset: AVAsset!
    
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
        asset = AVAsset(url: pickedURL!)
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        playerLayer = AVPlayerLayer(player: player)
        videoView.frame = self.view.bounds
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        player.play()
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { [weak self] _ in self?.restart() }
    }
    
    private func restart() {
        player.seek(to: .zero)
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
        livePhotoDemo()
    }
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreButtonDidTap(_ sender: Any) {
        var item: [Any] = []
        let ac = UIActivityViewController(activityItems: item, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func livePhotoDemo() {
        LivePhoto.generate(from: nil, videoURL: pickedURL!, progress: { (percent) in
            
        }) { (livePhoto, resources) in
            if let resources = resources {
                LivePhoto.saveToLibrary(resources, completion: { (success) in
                    if success {
                        self.saveWallpaper()
                        self.postAlert("Live Photo Saved", message:"The live photo was successfully saved to Photos.")
                    }
                    else {
                        self.postAlert("Live Photo Not Saved", message:"The live photo was not saved to Photos.")
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

extension PreviewVC {
    func saveWallpaper() {
        let amongUsDao = AmongUsDao()
        if let amongUs = amongUs {
            generateImage(for: self.asset) { [weak self] cgImage in
                let wallpaperURL = amongUs.getLocalWallpaperURL()
                if let data = UIImage.init(cgImage: cgImage).jpegData(compressionQuality: 0.8),
                   !FileManager.default.fileExists(atPath: wallpaperURL.path) {
                    do {
                        try data.write(to: wallpaperURL)
                        print("File saved at: \(wallpaperURL.absoluteString)")
                        amongUsDao.saveWallpaper(amongUs.realmEntity())
                    } catch {
                        print("error saving file:", error)
                    }
                }
            }
        }
    }
    
    fileprivate func generateImage(for asset: AVAsset, completion: ((CGImage) -> Void)?) {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let videoSize = asset.tracks(withMediaType: .video).first?.naturalSize else {return}
        
        generator.maximumSize = videoSize
        
        let times = [NSValue(time: CMTime(value: Int64((asset.duration.seconds * 1000) / 2), timescale: 1000))]
        
        generator.generateCGImagesAsynchronously(forTimes: times) { [weak self] (_, cgimage, _, result, error) in
            if let cgimage = cgimage, error == nil && result == AVAssetImageGenerator.Result.succeeded {
                DispatchQueue.main.async {
                    completion?(cgimage)
                }
            }
        }
    }
}
