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

enum StatusWallpaper {
    case `default`
    case editting
}

class MyWallpaperVC: UIViewController, StoryboardInstantiatable {
    
    static var storyboardName: AppStoryboard = .myWallpaper
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var wallpapers: [AmongUsModel] = []
    private var backgroundWallpaper: [UIImage] = []
    private var dispatchGroup = DispatchGroup()
    private var status: StatusWallpaper = .default
    private var deleteIndex: [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerCell(type: MyWallpaperCell.self)
        registerNotification()
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateAmongUs(_:)), name: .didSaveAmongUsKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editButtonDidTap(_:)), name: .didEditMyWallpaper, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getWallpapers()
        self.deleteIndex = []
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        StaticDataProvider.shared.cellSize = CGSize(width: (self.collectionView.frame.width/2)-12, height: self.view.frame.height * Const.ratioHeight)
        resizeAllWallpaper()
    }
    
    @objc func editButtonDidTap(_ sender: Any) {
        if status == .default {
            status = .editting
            if let homeVC = self.parent as? HomeVC {
                homeVC.editButton.setTitle("Delete", for: .normal)
                homeVC.editButton.setTitleColor(.red, for: .normal)
            }
            
            self.collectionView.reloadData()
        } else {
            let deleteWallpaper = self.deleteIndex.map({self.wallpapers[$0.row]})
            if deleteWallpaper.isEmpty {
                self.status = .default
                if let homeVC = self.parent as? HomeVC {
                    homeVC.editButton.setTitle("Edit", for: .normal)
                    homeVC.editButton.setTitleColor(.white, for: .normal)
                }
                
                self.collectionView.reloadData()
                return
            }
            
            showAlert(title: "Warning", message: "Are you sure to delete?", titleButtons: ["OK", "Cancel"], destructiveIndexs: [0]) { [weak self] (index) in
                guard let `self` = self else {return}
                
                if index == 0 {
                    self.status = .default
                    if let homeVC = self.parent as? HomeVC {
                        homeVC.editButton.setTitle("Edit", for: .normal)
                        homeVC.editButton.setTitleColor(.white, for: .normal)
                    }
                    
                    self.deleteWallpapers(wallpapers: deleteWallpaper)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func showAlert(title: String = "", message: String = "", titleButtons: [String] = ["OK"], destructiveIndexs: [Int] = [], action: ((Int) -> Void)? = nil) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertController.Style.alert)

        titleButtons.forEach { (titleButton) in
            let index = titleButtons.firstIndex(of: titleButton)!
            let style = destructiveIndexs.contains(index) ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
            let alertAction = UIAlertAction.init(title: titleButton, style: style, handler: { (_) in
                action?(index)
            })

            alert.addAction(alertAction)
        }

        self.present(alert, animated: true, completion: nil)
    }
}

extension MyWallpaperVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.collectionView.frame.width/2)-12, height: self.view.frame.height * Const.ratioHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if status == .default {
            let wallpaper = self.wallpapers[indexPath.row]
            
            let amongUsMainVC = AmongUsMainVC.instantiate()
            amongUsMainVC.configForEditing(amongUs: wallpaper)
            self.navigationController?.pushViewController(amongUsMainVC, animated: true)
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? MyWallpaperCell else {return}
            
            cell.status = !cell.status
            if cell.status {
                deleteIndex.append(indexPath)
            } else {
                deleteIndex.removeAll(where: {$0 == indexPath})
            }
        }
    }
}

extension MyWallpaperVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return backgroundWallpaper.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: MyWallpaperCell.self, indexPath: indexPath)
        //TODO: add image async
        if status == .editting {
            cell?.prepareForEditting()
        } else {
            cell?.pickImageView.isHidden = true
        }
        
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
    
    func deleteWallpapers(wallpapers: [AmongUsModel]) {
        let amongUsDao = AmongUsDao()
        let wallpaperIds = wallpapers.map {$0.id}
        amongUsDao.deleteWallpapers(wallpaperIds)
        self.deleteIndex = []
        getWallpapers()
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
