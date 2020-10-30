//
//  PlayerView.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 10/30/20.
//

import UIKit
import AVFoundation

protocol PlayerViewDelegate: class {
    func playerView(_ view: PlayerView, isReadyToPlay: Bool)
}

class PlayerView: UIView {
    var asset: AVAsset!
    
    weak var delegate: PlayerViewDelegate?
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            playerLayer.player = newValue
        }
    }
        
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var playCompletion: (() -> Void)?
    private var playerItemContext = 0
    private var playerContext = 1

    // Keep the reference and use it to observe the loading status.
    var playerItem: AVPlayerItem?
    
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset)
            case .failed:
                print(".failed")
            case .cancelled:
                print(".cancelled")
            case .loading:
                print("loading")
            default:
                print("default")
            }
        }
    }
    
    func setupPlayerItem(asset: AVAsset?, videoComposition: AVVideoComposition? = nil) {
        guard let asset = asset else {
            return
        }
        
        DispatchQueue.main.async {
            self.playerItem = AVPlayerItem.init(asset: asset)
            self.playerItem?.videoComposition = videoComposition
            self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &self.playerItemContext)
            if self.player?.currentItem != nil {
                self.player?.replaceCurrentItem(with: self.playerItem)
            } else {
                self.player = AVPlayer(playerItem: self.playerItem!)
            }
            self.asset = asset
        }
    }
    
    func apply(with videoComposition: AVVideoComposition?) {
        guard let playerItem = self.player?.currentItem else {return}
        
        playerItem.videoComposition = videoComposition
    }
    
    func adjustVolume(audioMix: AVAudioMix) {
        self.player?.currentItem?.audioMix = audioMix
    }
        
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                delegate?.playerView(self, isReadyToPlay: true)
            case .failed:
                print(".failed")
            case .unknown:
                print(".unknown")
            @unknown default:
                delegate?.playerView(self, isReadyToPlay: false)
                print("@unknown default")
            }
        }
    }
    
    func play(with url: URL, completion: ((_ asset: AVAsset) -> Void)? = nil) {
        setUpAsset(with: url) { [weak self] (asset: AVAsset) in
            DispatchQueue.main.async {
                completion?(asset)
            }
            self?.setupPlayerItem(asset: asset, videoComposition: nil)
        }
    }

    func play(asset: AVAsset, videoComposition: AVVideoComposition?) {
        setupPlayerItem(asset: asset, videoComposition: videoComposition)
    }
    
    func resume(completion: (() -> Void)? = nil) {
        player?.play()
        DispatchQueue.main.async {
            completion?()
        }
    }
    
    func stop(completion: (() -> Void)? = nil) {
        player?.pause()
        DispatchQueue.main.async {
            completion?()
        }
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        print("deinit of PlayerView")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.frame
    }
}
