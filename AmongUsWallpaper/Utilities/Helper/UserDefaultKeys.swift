//
//  UserDefaultKeys.swift
//  AmongUsWallpaper
//
//  Created by Le Toan  on 11/8/20.
//

import Foundation

class UserDefaultKeys {
    static let showInappKey = "ShowInappKey"
}

extension UserDefaults {
    class var isShowInapp: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultKeys.showInappKey)
    }
}
