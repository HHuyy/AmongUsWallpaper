//
//  SettingVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit

enum SettingUseCase: CaseIterable {
    case shareApp
    case contactUs
    case termOfUse
    case privacy
    
    var data: SettingModel {
        switch self {
        case .shareApp: return SettingModel(image: UIImage(named: "ic_shareapp")!, title: "Rate app")
        case .contactUs: return SettingModel(image: UIImage(named: "ic_contactus")!, title: "Contact us")
        case .termOfUse: return SettingModel(image: UIImage(named: "ic_termofuse")!, title: "Term of User")
        case .privacy: return SettingModel(image: UIImage(named: "ic_privacy")!, title: "Privacy Policy")
        }
    }
}

class SettingVC: UIViewController, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .setting

    @IBOutlet weak var premiumView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var settingData: [SettingModel] = {
        return SettingUseCase.allCases.map({$0.data})
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGesture()
        collectionView.registerCell(type: SettingCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        premiumView.layer.cornerRadius = 17.0
//        let layout = UICollectionViewLayout()
//        collectionView.collectionViewLayout = layout
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        premiumView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: Any) {
        // open inapp
    }
}

extension SettingVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width-12)/2, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            AppStoreReviewManager.requestReviewIfAppropriate()
        case 1:
            let contactUsVC = ContactUsViewController.instantiate()
            self.navigationController?.pushViewController(contactUsVC, animated: true)
        case 2:
            let termOfUseVC = TermOfUseVC.instantiate()
            self.navigationController?.pushViewController(termOfUseVC, animated: true)
        case 3:
            let privacyVC = PrivacyVC.instantiate()
            self.navigationController?.pushViewController(privacyVC, animated: true)
        default:
            break
        }
    }
}

extension SettingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(type: SettingCell.self, indexPath: indexPath)
        cell!.bindData(model: settingData[indexPath.row])
        return cell!
    }
}
