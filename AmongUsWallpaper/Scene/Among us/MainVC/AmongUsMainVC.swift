//
//  AmongUsMainVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit
import UITextView_Placeholder
import SnapKit

struct AUIconCellModel {
    var imageName: String
    var isSelected: Bool
}

enum VideoType: String {
    case mp4 = "mp4"
}

private struct Const {
    static let placeholder: String = "Enter text here ..."
    static let maxLines: CGFloat = 3
}

class AmongUsMainVC: UIViewController {

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var iconContainView: UIView!
    @IBOutlet weak var fontContainView: UIView!
    @IBOutlet weak var backgroundContainView: UIView!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    
    @IBOutlet weak var editView: PlayerView!
    @IBOutlet weak var editTextView: UITextView!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var heightEditTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthEditTextViewConstraint: NSLayoutConstraint!
    
    private var videoEditor: VideoEditor!
    
    var iconArray: [String]! = []
    var selectedIndex = 0
    
    private var currentAttrString: NSAttributedString!
    private var currentCoordinate: Coordinate!
    private var videoType: VideoType = .mp4
    private var currentBackground: String = "8"
    private var currentTextColor: UIColor = .white
    private var previousText: String = ""
    
    private var defaultHeight: CGFloat = 0.0
    
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
        self.videoEditor = VideoEditor(fileName: self.currentBackground, type: videoType.rawValue)
        self.editView.setupPlayerItem(asset: videoEditor.composition)
        self.editView.delegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        editView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        editView.layer.shadowColor = UIColor.lightGray.cgColor
        editView.layer.shadowOpacity = 0.8
    }
    
    func setupUI() {
        iconButton.isSelected = true
        fontButton.isSelected = false
        backgroundButton.isSelected = false
        
        iconContainView.isHidden = false
        fontContainView.isHidden = true
        backgroundContainView.isHidden = true
        
        setupEditView()
    }
    
    func setupEditView() {
        self.view.layoutIfNeeded()
        editImageView.contentMode = .scaleAspectFill
        editTextView.delegate = self
        editTextView.backgroundColor = .clear
        editTextView.isScrollEnabled = false
        editTextView.attributedPlaceholder = NSAttributedString(string: Const.placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)])
        editTextView.font = UIFont.systemFont(ofSize: 15)
        
        editTextView.textColor = self.currentTextColor
        
        defaultHeight = editTextView.sizeForText(text: editTextView.attributedPlaceholder, width: self.editView.frame.width-20).height
        heightEditTextViewConstraint.constant = defaultHeight
        widthEditTextViewConstraint.constant = editTextView.sizeForText(text: editTextView.attributedPlaceholder, width: self.editView.frame.width-20).width + editTextView.textContainer.lineFragmentPadding*2
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapPreviewButton(_ sender: Any) {
        showPreview()
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
    
    func showPreview() {
        let attrs: [NSAttributedString.Key : Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.white
        ]
        
        let testAttrString = NSAttributedString(string: "THIS IS MY PHONE", attributes: attrs)
        let testCoordinate = Coordinate(x: 20, y: self.editView.frame.maxY/2 - testAttrString.height(containerWidth: self.editView.frame.width - 40))
        self.currentCoordinate = testCoordinate
        
        self.videoEditor = VideoEditor(fileName: currentBackground, type: videoType.rawValue)
        
        let videoCompostion = self.videoEditor.build(attrString: testAttrString, position: self.currentCoordinate)
//        self.editView.apply(with: videoCompostion)
        
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
        self.editImageView.image = UIImage(named: iconArray[selectedIndex])
        collectionView.reloadData()
    }

}

extension AmongUsMainVC: PlayerViewDelegate {
    func playerView(_ view: PlayerView, isReadyToPlay: Bool) {
        if isReadyToPlay {
            view.player?.play()
        }
    }
}

extension AmongUsMainVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var resizedContent = textView.attributedPlaceholder
        if !textView.text.isEmpty {
            resizedContent = textView.attributedText
        }
        
        var contentWidth = resizedContent!.width(containerHeight: heightEditTextViewConstraint.constant) + textView.textContainer.lineFragmentPadding*2
        print(contentWidth)
        if contentWidth > self.editView.frame.width - 20 - textView.textContainer.lineFragmentPadding*2 {
            let realHeight = resizedContent!.height(containerWidth: widthEditTextViewConstraint.constant - textView.textContainer.lineFragmentPadding*2) + textView.textContainerInset.top + textView.textContainerInset.bottom
            if heightEditTextViewConstraint.constant <= realHeight {
                if realHeight >= defaultHeight * Const.maxLines {
                    textView.text = self.previousText
                    print("Max length, please delete")
                } else {
                    heightEditTextViewConstraint.constant = realHeight
                    contentWidth = widthEditTextViewConstraint.constant
                }
            }
            
            print("contentHeight: \(heightEditTextViewConstraint.constant)")
        } else {
            widthEditTextViewConstraint.constant = contentWidth
            if heightEditTextViewConstraint.constant > defaultHeight {
                heightEditTextViewConstraint.constant = resizedContent!.height(containerWidth: widthEditTextViewConstraint.constant - textView.textContainer.lineFragmentPadding*2) + textView.textContainerInset.top + textView.textContainerInset.bottom
            }
        }
        
        self.previousText = textView.text
        print(widthEditTextViewConstraint.constant)
    }
}
