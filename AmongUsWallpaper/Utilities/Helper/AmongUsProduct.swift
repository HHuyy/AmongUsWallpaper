//
//  Product.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 11/8/20.
//

import Foundation

enum InappId: String {
    case buyOne = "com.amonguswallpaper.inapp.buyone"
}

public struct AmongUsProduct {
    private static let productIdentifiers: Set<ProductIdentifier> = [InappId.buyOne.rawValue]
    
    public static let store = IAPHelper(productIds: AmongUsProduct.productIdentifiers)
}
