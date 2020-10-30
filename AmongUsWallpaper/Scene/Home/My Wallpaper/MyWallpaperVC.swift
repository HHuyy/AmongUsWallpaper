//
//  MyWallpaperVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

private struct Const {
    static let ratioHeight: CGFloat = 313/896
}

struct WallpaperModel {
    
}

class MyWallpaperVC: UIViewController, StoryboardInstantiatable {
    
    static var storyboardName: AppStoryboard = .myWallpaper
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var wallpaper: [WallpaperModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: MyWallpaperCell.self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fetch data
    }
}

extension MyWallpaperVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width-12)/2, height: self.view.frame.height * Const.ratioHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension MyWallpaperVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpaper.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: MyWallpaperCell.self, indexPath: indexPath)
        //TODO: add image async
        cell?.bindData(backgroundImage: UIImage())
        return cell!
    }
}
