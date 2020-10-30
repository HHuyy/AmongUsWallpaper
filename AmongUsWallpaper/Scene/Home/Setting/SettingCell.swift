//
//  SettingCell.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 10/30/20.
//

import UIKit

struct SettingModel {
    let image: UIImage
    let title: String
}

class SettingCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindData(model: SettingModel) {
        self.titleLabel.text = model.title
        self.iconImageView.image = model.image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 20.0
    }
}
