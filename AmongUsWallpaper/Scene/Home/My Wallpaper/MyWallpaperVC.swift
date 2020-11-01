//
//  MyWallpaperVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

private struct Const {
    static let ratioHeight: CGFloat = 350/896
}

class MyWallpaperVC: UIViewController, StoryboardInstantiatable {
    
    static var storyboardName: AppStoryboard = .myWallpaper
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var wallpapers: [AmongUsModel] = []
    private var backgroundWallpaper: [UIImage] = []
    
    private var cellSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: MyWallpaperCell.self)
        self.getWallpapers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cellSize = CGSize(width: (self.collectionView.frame.width/2)-12, height: self.view.frame.height * Const.ratioHeight)
        resizeAllWallpaper()
    }
}

extension MyWallpaperVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width/2)-12, height: self.view.frame.height * Const.ratioHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let editVC = 
    }
}

extension MyWallpaperVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgroundWallpaper.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: MyWallpaperCell.self, indexPath: indexPath)
        //TODO: add image async
        cell?.bindData(backgroundImage: self.backgroundWallpaper[indexPath.row])
        return cell!
    }
}

extension MyWallpaperVC {
    func getWallpapers() {
        let amongUsDao = AmongUsDao()
        self.wallpapers = amongUsDao.getWallpaper()
        
        for wallpaper in wallpapers {
            guard let data = try? Data(contentsOf: wallpaper.getLocalWallpaperURL()) else {return}
            
            if let image = UIImage(data: data) {
                self.backgroundWallpaper.append(image)
            }
        }
    }
    
    func resizeAllWallpaper() {
        self.backgroundWallpaper = self.backgroundWallpaper.map {$0.resize(to: self.cellSize)}
        self.collectionView.reloadData()
    }
    
    func setUpItems() {
        
    }
}
