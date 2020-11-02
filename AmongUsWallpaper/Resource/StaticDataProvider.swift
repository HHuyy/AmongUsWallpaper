//
//  StaticDataProvider.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/2/20.
//

import Foundation
class StaticDataProvider {
    public static let shared = StaticDataProvider()
    
    private init() {
    }
    
    lazy var listFonts: [String] = {
        guard let url = Bundle.main.url(forResource: "font_resource", withExtension: "json"),
            let data = try? Data(contentsOf: url) else {return []}
        
        if let fonts = try? JSONDecoder().decode([FontModel].self, from: data) {
            return fonts.map({$0.fontName})
        } else {
            print("Fail to get list font")
            return []
        }
    }()

}
