//
//  MyWallpaperCell.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 10/30/20.
//

import UIKit

class MyWallpaperCell: UICollectionViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var pickImageView: UIImageView!
    
    var status: Bool = false {
        didSet {
            if !status {
                pickImageView.image = UIImage(named: "ic_unselected")
            } else {
                pickImageView.image = UIImage(named: "ic_selected")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        pickImageView.isHidden = true
    }
    
    func bindData(backgroundImage: UIImage) {
        playImageView.image = UIImage(named: "ic_play")
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func prepareForEditting() {
        pickImageView.isHidden = false
        if !status {
            pickImageView.image = UIImage(named: "ic_unselected")
        } else {
            pickImageView.image = UIImage(named: "ic_selected")
        }
    }
}
