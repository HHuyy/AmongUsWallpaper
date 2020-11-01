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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
}
