//
//  IconCell.swift
//  AmongUsWallpaper
//
//  Created by Brite Solutions on 10/29/20.
//

import UIKit

class IconCell: UICollectionViewCell {
    
    @IBOutlet weak var imageIcon: UIImageView!
    
    @IBOutlet weak var bottomView: RoundUIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindData(_ image: UIImage) {
        DispatchQueue.main.async {
            self.imageIcon.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageIcon.image = nil
    }
}
