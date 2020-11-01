//
//  AmongUsMainVC.swift
//  AmongUsWallpaper
//
//  Created by manhpro on 10/28/20.
//

import UIKit
import UITextView_Placeholder
import SnapKit
import Photos
import PhotosUI

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
    static let originVideoHeight: CGFloat = 1920
}

class AmongUsMainVC: UIViewController, UIGestureRecognizerDelegate, PHLivePhotoViewDelegate {

    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var fontButton: UIButton!
    @IBOutlet weak var backgroundButton: UIButton!
    @IBOutlet weak var iconContainView: UIView!
    @IBOutlet weak var fontContainView: UIView!
    @IBOutlet weak var backgroundContainView: UIView!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    @IBOutlet weak var fontStyleCollectionView: UICollectionView!
    @IBOutlet weak var fontColorCollectionView: UICollectionView!
    @IBOutlet weak var backgroundCollectionView: UICollectionView!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet var alignmentButtons: [UIButton]!
    
    @IBOutlet weak var editContainerView: UIView!
    @IBOutlet weak var editView: PlayerView!
    @IBOutlet weak var editTextView: UITextView!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var heightEditTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthEditTextViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightEditContainerViewConstraint: NSLayoutConstraint!
    
    private var videoEditor: VideoEditor!
    
    var iconArray: [String]! = []
    var fontStyleArray: [String]! = []
    var fontColorArray: [UInt]! = []
    var backgroundArray: [String]! = []
    var reSizebackgroundArray: [UIImage] = []
    var iconSelectedIndex = 0
    var fontStyleSelectedIndex = 0
    var fontColorSelectedIndex = 0
    var backgroundSelectedIndex = 0
    var positionY: CGFloat?
//    var currentPosition: CGAffineTransform?

    var currentAlignment: TextAlignment = .left
    var currentIconDirection: Bool = false
    
    
    private var currentAttrString: NSAttributedString!
    private var currentCoordinate: Coordinate!
    private var videoType: VideoType = .mp4
    private var currentBackground: String = "1"
    private var currentTextColor: UIColor = .white
    private var previousText: String = ""
    
    private var defaultHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconCollectionView.register(UINib.init(nibName: "IconCell", bundle: .main), forCellWithReuseIdentifier: "IconCell")
        self.fontStyleCollectionView.register(UINib.init(nibName: "fontStyleCell", bundle: .main), forCellWithReuseIdentifier: "fontStyleCell")
        self.fontColorCollectionView.register(UINib.init(nibName: "fontColorCell", bundle: .main), forCellWithReuseIdentifier: "fontColorCell")
        self.backgroundCollectionView.register(UINib.init(nibName: "backgroundCell", bundle: .main), forCellWithReuseIdentifier: "backgroundCell")
        var i = 1
        while i <= 41 {
            iconArray?.append("icon-\(i)")
            i += 1
            iconCollectionView.reloadData()
        }
        self.fontStyleArray = ["ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold", "ArialRoundedMTBold"]
        fontStyleCollectionView.reloadData()
        editTextView.textAlignment = .left
        self.fontColorArray = [0xFFFFFF, 0xF98B8E, 0xFFA1EC, 0x9D9AFB, 0xA7FEF5, 0xA7FF97, 0xFFCA7B, 0xFF9D9C] // add 0x at the beginning of hex color code
        editTextView.textColor = UIColor.init(rgb: fontColorArray[0])
        fontColorCollectionView.reloadData()
        backgroundArray = ["1", "2", "3", "4", "5", "6", "7", "8"]
        backgroundArray.forEach { (i) in
            let reSizeBG = resizeImage(image: UIImage.init(named: i)!, targetSize: CGSize(width: 70, height: 108))
            
            reSizebackgroundArray.append(reSizeBG)
        }
        backgroundCollectionView.reloadData()
        
        editTextView.textContainer.maximumNumberOfLines = 3
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        pan.delegate = self
//        editContainerView.addGestureRecognizer(pan)
//        editTextView.addGestureRecognizer(pan)
        editImageView.addGestureRecognizer(pan)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
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
        editTextView.isUserInteractionEnabled = false
        editImageView.isUserInteractionEnabled = true
        
        iconContainView.isHidden = false
        fontContainView.isHidden = true
        backgroundContainView.isHidden = true
        
        iconButton.isSelected = true
        fontButton.isSelected = false
        backgroundButton.isSelected = false
        
        iconContainView.isHidden = false
        fontContainView.isHidden = true
        backgroundContainView.isHidden = true
        
        self.videoEditor = VideoEditor(fileName: self.currentBackground, type: videoType.rawValue)
        self.editView.setupPlayerItem(asset: videoEditor.composition)
        self.editView.delegate = self
        
        positionY = editView.frame.width/2
        
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
//        heightEditContainerViewConstraint.constant = defaultHeight + 10
        widthEditTextViewConstraint.constant = editTextView.sizeForText(text: editTextView.attributedPlaceholder, width: self.editView.frame.width-20).width + editTextView.textContainer.lineFragmentPadding*2
    }
    
    @IBAction func tapBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapPreviewButton(_ sender: Any) {
//        showPreview()
        showDemo()
    }
    
    @IBAction func tapTabButtons(_ sender: UIButton) {
        iconButton.isSelected = false
        fontButton.isSelected = false
        backgroundButton.isSelected = false
        
        sender.isSelected = true
        switch sender {
        case iconButton:
            print("iconButton")
            editTextView.isUserInteractionEnabled = false
            editImageView.isUserInteractionEnabled = true
            self.view.endEditing(true)
            iconContainView.isHidden = false
            fontContainView.isHidden = true
            backgroundContainView.isHidden = true
        case fontButton:
            print("fontButton")
            editTextView.isUserInteractionEnabled = true
            editImageView.isUserInteractionEnabled = false
            iconContainView.isHidden = true
            fontContainView.isHidden = false
            backgroundContainView.isHidden = true
        case backgroundButton:
            print("backgroundButton")
            editTextView.isUserInteractionEnabled = false
            editImageView.isUserInteractionEnabled = true
            self.view.endEditing(true)
            iconContainView.isHidden = true
            fontContainView.isHidden = true
            backgroundContainView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func tapAlignmentButton(_ sender: UIButton) {
        alignmentButtons.forEach { (button) in
            button.isSelected = false
        }
        sender.isSelected = true
        switch sender.tag {
        case 1:
            editTextView.textAlignment = .left
            currentAlignment = .left
        case 2:
            editTextView.textAlignment = .center
            currentAlignment = .center
        case 3:
            editTextView.textAlignment = .right
            currentAlignment = .right
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
    
    private let editor = VideoEditors()
    func showDemo() {
        let backgroundImage = backgroundArray[backgroundSelectedIndex]
        let icon = iconArray[iconSelectedIndex]
        let text = (editTextView.text!.isEmpty) ? editTextView.placeholder : editTextView.text!
        let fontSize = Float(editTextView.font!.pointSize)
        let font = editTextView.font!.fontName
        let textColor: UInt = fontColorArray[fontColorSelectedIndex]
        let position: Float = Float(positionY!)
        
        let urlPath = Bundle.main.url(forResource: backgroundArray[backgroundSelectedIndex], withExtension: "mp4")!
//        let icon = resizeImage(image: UIImage.init(named: iconArray[iconSelectedIndex])!, targetSize: CGSize(width: editImageView.frame.width, height: editImageView.frame.height))
        self.editor.makeVideo(fromVideoAt: urlPath, icon: UIImage.init(named: iconArray[iconSelectedIndex])!, fontStyle: fontStyleArray[fontStyleSelectedIndex], textString: editTextView.text, textColor: fontColorArray[fontColorSelectedIndex], background: reSizebackgroundArray[backgroundSelectedIndex], textSize: editTextView.font!.pointSize, alignment: currentAlignment, y: positionY!/editView.frame.height, scale: Const.originVideoHeight / editView.frame.height) { exportedURL in
            guard let exportedURL = exportedURL else {
                return
            }
            
            // Refactor
            let previewVC = PreviewVC.instantiate()
            let id = exportedURL.deletingPathExtension().lastPathComponent
            
            let amongUsModel = AmongUsModel(id: id, position: position,
                                            backgoundImage: backgroundImage, icon: icon,
                                            text: text ?? "", fontSize: fontSize, font: font,
                                            textColor: textColor, iconDirection: self.currentIconDirection, textAlignment: self.currentAlignment)
            
            previewVC.pickedURL = exportedURL
            previewVC.amongUs = amongUsModel
            self.navigationController?.pushViewController(previewVC, animated: true)
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        if gesture.state == .began {
//            print("began")
//            if let position = currentPosition {
//                editContainerView.transform = CGAffineTransform(translationX: 0, y: position.ty)
//                print(position.ty)
//            }
//        } else if gesture.state == .changed {
//            print("changed")
//            let translation = gesture.translation(in: self.editView)
//            editContainerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
////            print(translation.y)
//        } else if gesture.state == .ended {
//            print("ended")
//            let translation = gesture.translation(in: self.editView)
//            currentPosition = CGAffineTransform(translationX: 0, y: translation.y)
////            print(translation.y)
//        }
        let translation = gesture.translation(in: self.editView)
        let centerY = editTextView.center.y + translation.y
        if centerY < 340, centerY > 40 {
            editTextView.center = CGPoint(x: editTextView.center.x, y: editTextView.center.y + translation.y)
        } else {
            editTextView.center = CGPoint(x: editTextView.center.x, y: editTextView.center.y)
        }
        editImageView.center = CGPoint(x: editImageView.center.x, y: editTextView.center.y)
        gesture.setTranslation(CGPoint.zero, in: self.editView)
        positionY = editTextView.center.y
        print(editTextView.center.y)
    }
}

extension AmongUsMainVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case iconCollectionView:
            return CGSize(width: 50, height: collectionView.frame.height)
        case fontStyleCollectionView:
            return CGSize(width: 50, height: collectionView.frame.height)
        case fontColorCollectionView:
            return CGSize(width: 50, height: collectionView.frame.height)
        case backgroundCollectionView:
            return CGSize(width: 70, height: collectionView.frame.height)
        default:
            return CGSize(width: 0, height: 0)
        }
        
    }
}

extension AmongUsMainVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case iconCollectionView:
            return iconArray.count
        case fontStyleCollectionView:
            return fontStyleArray.count
        case fontColorCollectionView:
            return fontColorArray.count
        case backgroundCollectionView:
            return backgroundArray.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case iconCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as? IconCell else {
                return UICollectionViewCell()
            }

            DispatchQueue.global(qos: .background).async {
                let image = UIImage(named: self.iconArray[indexPath.row])

                DispatchQueue.main.async {
                    cell.imageIcon.image = image
                }
            }
            if indexPath.row == iconSelectedIndex {
                cell.bottomView.isHidden = false
            } else {
                cell.bottomView.isHidden = true
            }
            return cell
        case fontStyleCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fontStyleCell", for: indexPath) as? fontStyleCell else {
                return UICollectionViewCell()
            }
//            let attributedString = NSAttributedString(
//                string: "Text",
//                attributes: [
//                    .font: UIFont(name: fontStyleArray[indexPath.row], size: 15) as Any,
//                .foregroundColor: UIColor.green])
            cell.styleLabel.font = UIFont(name: fontStyleArray[indexPath.row], size: 17)
            if indexPath.row == fontStyleSelectedIndex {
                cell.styleLabel.textColor = UIColor.init(rgb: 0xFFA734)
                cell.bottomView.isHidden = false
            } else {
                cell.styleLabel.textColor = UIColor.init(rgb: 0x9EB0CC)
                cell.bottomView.isHidden = true
            }
            return cell
        case fontColorCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "fontColorCell", for: indexPath) as? fontColorCell else {
                return UICollectionViewCell()
            }
            cell.colorView.backgroundColor = UIColor.init(rgb: fontColorArray[indexPath.row])
            if indexPath.row == fontColorSelectedIndex {
                cell.bottomView.isHidden = false
            } else {
                cell.bottomView.isHidden = true
            }
            return cell
        case backgroundCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "backgroundCell", for: indexPath) as? backgroundCell else {
                return UICollectionViewCell()
            }
            cell.backgroundImage.image = reSizebackgroundArray[indexPath.row]
            if indexPath.row == backgroundSelectedIndex {
                cell.bottomView.isHidden = false
            } else {
                cell.bottomView.isHidden = true
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case iconCollectionView:
            iconSelectedIndex = indexPath.row
            self.editImageView.image = UIImage(named: iconArray[iconSelectedIndex])
        case fontStyleCollectionView:
            fontStyleSelectedIndex = indexPath.row
            self.editTextView.font = UIFont(name: fontStyleArray[indexPath.row], size: self.editTextView.font!.pointSize)
        case fontColorCollectionView:
            fontColorSelectedIndex = indexPath.row
            self.editTextView.textColor = UIColor.init(rgb: fontColorArray[indexPath.row])
        case backgroundCollectionView:
            backgroundSelectedIndex = indexPath.row
            currentBackground = backgroundArray[indexPath.row]
            self.videoEditor = VideoEditor(fileName: self.currentBackground, type: videoType.rawValue)
            self.editView.setupPlayerItem(asset: videoEditor.composition)
        default:
            break
        }
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
//        print(contentWidth)
        if contentWidth > self.editView.frame.width - 20 - textView.textContainer.lineFragmentPadding*2 {
            let realHeight = resizedContent!.height(containerWidth: widthEditTextViewConstraint.constant - textView.textContainer.lineFragmentPadding*2) + textView.textContainerInset.top + textView.textContainerInset.bottom
            if heightEditTextViewConstraint.constant <= realHeight {
                if realHeight >= defaultHeight * Const.maxLines {
                    textView.text = self.previousText
                    print("Max length, please delete")
                } else {
                    heightEditTextViewConstraint.constant = realHeight
//                    heightEditContainerViewConstraint.constant = realHeight + 10
                    contentWidth = widthEditTextViewConstraint.constant
                }
            }
            
            print("contentHeight: \(heightEditTextViewConstraint.constant)")
        } else {
            widthEditTextViewConstraint.constant = contentWidth
            if heightEditTextViewConstraint.constant > defaultHeight {
                heightEditTextViewConstraint.constant = resizedContent!.height(containerWidth: widthEditTextViewConstraint.constant - textView.textContainer.lineFragmentPadding*2) + textView.textContainerInset.top + textView.textContainerInset.bottom
//                heightEditContainerViewConstraint.constant = heightEditTextViewConstraint.constant + 10
            }
        }
        
        self.previousText = textView.text
        print(widthEditTextViewConstraint.constant)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        return linesAfterChange <= textView.textContainer.maximumNumberOfLines
    }
}
