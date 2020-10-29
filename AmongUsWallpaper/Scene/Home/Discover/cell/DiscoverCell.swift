//
//  DiscoverCell.swift
//  AmongUsWallpaper
//
//  Created by Brite Solutions on 10/29/20.
//

import UIKit

class DiscoverCell: UITableViewCell {
    
    @IBOutlet weak var imageTheme: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
