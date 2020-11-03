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
    static let originVideoWidth: CGFloat = 1080
    static let minFontSize: CGFloat = 15
    static let maxFontSize: CGFloat = 35
}

class AmongUsMainVC: UIViewController, UIGestureRecognizerDelegate, PHLivePhotoViewDelegate, StoryboardInstantiatable {
    static var storyboardName: AppStoryboard = .amongUsMain
    
    // MARK: - IBOutlets
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
    
    // MARK: - Properties
    private var videoEditor: VideoEditor!
    
    lazy var iconArray: [String] = {
        var _temp = [String]()
        var i = 1
        while i <= 41 {
            _temp.append("icon-\(i)")
            i += 1
        }
        return _temp
    }()
    
    lazy var iconImageArray: [UIImage] = {
        var _temp = [UIImage]()
        return iconArray.map({
            UIImage(named: $0)!.resize(to: CGSize(width: 70, height: iconHeight))
        })
    }()
    
    lazy var fontStyleArray: [String] = {
        return StaticDataProvider.shared.listFonts
    }()
    
    lazy var fontColorArray: [UInt]! = {
        return [0xFFFFFF, 0xF98B8E, 0xFFA1EC, 0x9D9AFB, 0xA7FEF5, 0xA7FF97, 0xFFCA7B, 0xFF9D9C]
    }()
    
    lazy var backgroundArray: [String] = {
       return ["1", "2", "3", "4", "5", "6", "7", "8"]
    }()
    // TODO: - add color 
    lazy var backgroundColorArray: [UInt]! = {
        return []
    }()
    
    lazy var reSizebackgroundArray: [UIImage] = {
        var array = [UIImage]()
        backgroundArray.forEach { (i) in
            let reSizeBG = resizeImage(image: UIImage.init(named: i)!, targetSize: CGSize(width: 70, height: 108))
            
            array.append(reSizeBG)
        }
        return array
    }()
    
    var iconSelectedIndex = 0
    var fontStyleSelectedIndex = 0
    var fontColorSelectedIndex = 0
    var backgroundSelectedIndex = 0
    var positionY: CGFloat?
    var iconHeight: CGFloat = 50*3/2

    var currentAlignment: TextAlignment = .left
    var currentIconDirection: Bool = false
    
    private var currentAmongUs: AmongUsModel?
    private var currentFontSize: CGFloat = Const.minFontSize
    private var currentCoordinate: Coordinate!
    private var videoType: VideoType = .mp4
    private var currentBackground: String = "1"
    private var currentTextColor: UIColor = .white
    private var previousText: String = ""
    
    private var defaultHeight: CGFloat = 0.0
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iconCollectionView.register(UINib.init(nibName: "IconCell", bundle: .main), forCellWithReuseIdentifier: "IconCell")
        self.fontStyleCollectionView.register(UINib.init(nibName: "fontStyleCell", bundle: .main), forCellWithReuseIdentifier: "fontStyleCell")
        self.fontColorCollectionView.register(UINib.init(nibName: "fontColorCell", bundle: .main), forCellWithReuseIdentifier: "fontColorCell")
        self.backgroundCollectionView.register(UINib.init(nibName: "backgroundCell", bundle: .main), forCellWithReuseIdentifier: "backgroundCell")


        editTextView.textAlignment = .left
        editTextView.textColor = UIColor.init(rgb: fontColorArray[0])
        editTextView.textContainer.maximumNumberOfLines = 3
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        pan.delegate = self
        editImageView.addGestureRecognizer(pan)
        setupForEditting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        positionY = editView.frame.height/2
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
    
    // MARK: - Functions
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
        
        self.fontSizeSlider.minimumValue = Float(Const.minFontSize)
        self.fontSizeSlider.maximumValue = Float(Const.maxFontSize)
        setupEditView()
    }

    func setupForEditting() {
        guard let amongUs = self.currentAmongUs else {
            return
        }
        
        if let iconIndex = self.iconArray.enumerated().filter({$0.element == amongUs.icon}).first?.offset {
            self.iconSelectedIndex = iconIndex
        }
        
        if let fontIndex = self.fontStyleArray.enumerated().filter({$0.element == amongUs.font}).first?.offset {
            self.fontStyleSelectedIndex = fontIndex
        }
        
        if let fontColorIndex = self.fontColorArray.enumerated().filter({$0.element == amongUs.textColor}).first?.offset {
            self.fontColorSelectedIndex = fontColorIndex
        }
        
        if let backgroundIndex = self.backgroundArray.enumerated().filter({$0.element == amongUs.backgoundImage}).first?.offset {
            self.backgroundSelectedIndex = backgroundIndex
        }
        
        self.fontSizeSlider.value = amongUs.fontSize
        self.editTextView.font = UIFont(name: amongUs.font, size: CGFloat(amongUs.fontSize))
        self.editTextView.text = amongUs.text
        self.currentAlignment = amongUs.textAlignment
        self.positionY = CGFloat(amongUs.position)
        self.editTextView.center.y = self.positionY!
        
        self.iconCollectionView.reloadData()
        self.fontStyleCollectionView.reloadData()
        self.fontColorCollectionView.reloadData()
        self.backgroundCollectionView.reloadData()
    }
    
    func setupEditView() {
        editImageView.contentMode = .scaleAspectFill
        editTextView.delegate = self
        editTextView.backgroundColor = .clear
        editTextView.isScrollEnabled = false
        
        editTextView.textColor = self.currentTextColor
        configTextViewSize()
    }
    
    func configTextViewSize() {
        editTextView.attributedPlaceholder = NSAttributedString(string: Const.placeholder, attributes: [NSAttributedString.Key.foregroundColor: self.currentTextColor, NSAttributedString.Key.font: UIFont(name: fontStyleArray[fontStyleSelectedIndex], size: currentFontSize)])
        editTextView.font = UIFont(name: fontStyleArray[fontStyleSelectedIndex], size: currentFontSize)
        
        if !editTextView.text.isEmpty {
            heightEditTextViewConstraint.constant = editTextView!.sizeForText(text: editTextView.attributedText, width: self.editView.frame.width).height
            widthEditTextViewConstraint.constant = editTextView!.attributedText.width(containerHeight: heightEditTextViewConstraint.constant) + editTextView.textContainer.lineFragmentPadding*2
        } else {
            defaultHeight = editTextView.sizeForText(text: editTextView.attributedPlaceholder, width: self.editView.frame.width - 20).height
            heightEditTextViewConstraint.constant = defaultHeight
            widthEditTextViewConstraint.constant = editTextView!.attributedPlaceholder.width(containerHeight: heightEditTextViewConstraint.constant) + editTextView.textContainer.lineFragmentPadding*2
        }
        
        self.view.layoutIfNeeded()
    }
    
    // MARK: - Actions
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
    
    private let editor = VideoEditors()
    func showDemo() {
        let backgroundImage = backgroundArray[backgroundSelectedIndex]
        let icon = iconArray[iconSelectedIndex]
        let text = (editTextView.text!.isEmpty) ? editTextView.placeholder : editTextView.text!
        let fontSize = Float(editTextView.font!.pointSize)
        let font = editTextView.font!.fontName
        let textColor: UInt = fontColorArray[fontColorSelectedIndex]
        let position: Float = Float(positionY!)
        let backgroundColor = backgroundColorArray[backgroundSelectedIndex]
        
        let urlPath = Bundle.main.url(forResource: backgroundArray[backgroundSelectedIndex], withExtension: "mp4")!

        self.editor.makeVideo(fromVideoAt: urlPath, icon: UIImage.init(named: iconArray[iconSelectedIndex])!, fontStyle: fontStyleArray[fontStyleSelectedIndex], textString: editTextView.text, textColor: fontColorArray[fontColorSelectedIndex], background: reSizebackgroundArray[backgroundSelectedIndex], textSize: editTextView.font!.pointSize, alignment: currentAlignment, y: positionY!/editView.frame.height, scaleHeight: Const.originVideoHeight / editView.frame.height, scaleWidth: Const.originVideoWidth / editView.frame.width, textScaleHeight: editTextView.frame.height / editView.frame.height, textScaleWidth: editTextView.frame.width/editView.frame.width, backgroundColor: backgroundColor) { exportedURL in
            
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
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
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
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        let size = CGFloat(Int(sender.value))
        
        self.editTextView.font = UIFont(name: self.fontStyleArray[fontStyleSelectedIndex], size: size)
        configTextViewSize()
    }
}

extension AmongUsMainVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case iconCollectionView:
            self.iconHeight = collectionView.frame.height
            return CGSize(width: collectionView.frame.height * 2/3, height: collectionView.frame.height)
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
            cell.bindData(self.iconImageArray[indexPath.row])
                
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
            self.currentFontSize = self.editTextView.font!.pointSize
            self.configTextViewSize()
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

extension AmongUsMainVC {
    func configForEditing(amongUs: AmongUsModel) {
        self.currentAmongUs = amongUs
    }
}

// MARK: Slide Delegate
extension AmongUsMainVC {
    
}

extension AmongUsMainVC {
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
}
