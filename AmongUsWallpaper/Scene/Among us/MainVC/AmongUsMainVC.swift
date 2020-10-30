//
//  AmongUsMainVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

struct AUIconCellModel {
    var imageName: String
    var isSelected: Bool
}

class AmongUsMainVC: UIViewController {

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var iconContainView: UIView!
    @IBOutlet weak var fontContainView: UIView!
    @IBOutlet weak var backgroundContainView: UIView!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private let editor = VideoEditor()
    var pickedPhoto: URL?
    var pickedVideoURL: URL?
    var iconArray: [String]! = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconCollectionView.register(UINib.init(nibName: "IconCell", bundle: .main), forCellWithReuseIdentifier: "IconCell")
        var i = 1
        while i <= 41 {
            iconArray?.append("icon-\(i)")
            i += 1
            iconCollectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupUI() {
        progressView.isHidden = true
        iconButton.isSelected = true
        fontButton.isSelected = false
        backgroundButton.isSelected = false
        
        iconContainView.isHidden = false
        fontContainView.isHidden = true
        backgroundContainView.isHidden = true
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapPreviewButton(_ sender: Any) {
//        makeVideo()
    }
    
    @IBAction func tapTabButtons(_ sender: UIButton) {
        iconButton.isSelected = false
        fontButton.isSelected = false
        backgroundButton.isSelected = false
        
        sender.isSelected = true
        switch sender {
        case iconButton:
            print("iconButton")
        case fontButton:
            print("fontButton")
        case backgroundButton:
            print("backgroundButton")
        default:
            break
        }
    }
    
    func makeVideo() {
        if let urlPath = Bundle.main.url(forResource: "8", withExtension: "mp4") {
            self.editor.makeBirthdayCard(fromVideoAt: urlPath, forName: "") { (exportedURL) in
                guard let exportedURL = exportedURL else {
                  return
                }
                self.pickedVideoURL = exportedURL
                self.generateLivePhoto()
            }
        }
    }
    
    func generateLivePhoto() {
        
        if let urlPath = Bundle.main.url(forResource: "background-8", withExtension: "pdf") {
            pickedPhoto = urlPath
        } else {return}
        LivePhoto.generate(from: pickedPhoto!, videoURL: pickedVideoURL!, progress: { (percent) in
            self.progressView.isHidden = false
            self.progressView.progress = Float(percent)
        }) { (livePhoto, resources) in
            
        }
    }
}

extension AmongUsMainVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: collectionView.frame.height)
    }
}

extension AmongUsMainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iconArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCell else {
            return UICollectionViewCell()
        }
        cell.imageIcon.image = UIImage(named: iconArray[indexPath.row])
        if indexPath.row == selectedIndex {
            cell.bottomView.isHidden = false
        } else {
            cell.bottomView.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }

}
