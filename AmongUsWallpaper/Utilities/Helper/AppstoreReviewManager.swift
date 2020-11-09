//
//  AppstoreReviewManager.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 11/9/20.
//

import StoreKit

enum AppStoreReviewManager {
  static func requestReviewIfAppropriate() {
    SKStoreReviewController.requestReview()
  }
}
