//
//  UITextView+Ext.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 10/30/20.
//

import UIKit

extension UITextView {
    func sizeForText(text: NSAttributedString?, width: CGFloat) -> CGSize {
        var text = text
        if text?.string.suffix(1) != "\n" && text != nil {
            text = NSAttributedString(string: text!.string.appending("\n"))
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: self.font as Any]
        let largestSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        var rect: CGRect
        if let text = text {
            rect = text.boundingRect(with: largestSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        } else {
            rect = self.text.boundingRect(with: largestSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        }
        return rect.size
    }
}
