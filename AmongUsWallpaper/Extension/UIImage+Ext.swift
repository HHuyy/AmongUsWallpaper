//
//  UIImage+Ext.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/1/20.
//

import Foundation
import UIKit
import CoreGraphics

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(origin: CGPoint.zero, size:size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
}