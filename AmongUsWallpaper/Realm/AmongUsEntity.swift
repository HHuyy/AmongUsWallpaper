//
//  AmongUsEntity.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/1/20.
//

import RealmSwift

class AmongUsEntity: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var position: Float = 0.0
    @objc dynamic var backgoundImage: String = ""
    @objc dynamic var icon: String = ""
    @objc dynamic var text: String = ""
    @objc dynamic var fontSize: Float = 0.0
    @objc dynamic var font: String = ""
    @objc dynamic var textColor: String = ""
    @objc dynamic var iconDirection: Bool = true // True: clock, false: reverse clock
    @objc dynamic var textAlignment: String = TextAlignment.left.rawValue
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
