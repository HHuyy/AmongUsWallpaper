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
    private var dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: MyWallpaperCell.self)
        registerNotification()
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAmongUs(_:)), name: .didSaveAmongUsKey, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getWallpapers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StaticDataProvider.shared.cellSize = CGSize(width: (self.collectionView.frame.width/2)-12, height: self.view.frame.height * Const.ratioHeight)
        resizeAllWallpaper()
    }
}

extension MyWallpaperVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width/2)-12, height: self.view.frame.height * Const.ratioHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let wallpaper = self.wallpapers[indexPath.row]
        
        let amongUsMainVC = AmongUsMainVC.instantiate()
        amongUsMainVC.configForEditing(amongUs: wallpaper)
        self.navigationController?.pushViewController(amongUsMainVC, animated: true)
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
        self.backgroundWallpaper = []
        let amongUsDao = AmongUsDao()
        self.wallpapers = amongUsDao.getWallpaper()
        
        var count = 0
        DispatchQueue.main.async {
            for wallpaper in self.wallpapers {
                guard let data = try? Data(contentsOf: wallpaper.getLocalWallpaperURL()) else {return}
                
                if let image = UIImage(data: data) {
                    count += 1
                    self.backgroundWallpaper.append(image)
                    if count == self.wallpapers.count {
                        self.resizeAllWallpaper()
                    }
                }
            }
        }
    }
    
    func resizeAllWallpaper() {
        if self.backgroundWallpaper.first?.size == StaticDataProvider.shared.cellSize || StaticDataProvider.shared.cellSize == CGSize(width: 0, height: 0) {
            return
        }
        
        self.backgroundWallpaper = self.backgroundWallpaper.map {$0.resize(to: StaticDataProvider.shared.cellSize)}
        self.collectionView.reloadData()
    }
    
    func setUpItems() {
        
    }
}

// MARK: - Notification
extension MyWallpaperVC {
    @objc func didUpdateAmongUs(_ object: Notification) {
        self.getWallpapers()
    }
}
