//
//  AmongUsDAo.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/1/20.
//

import RealmSwift
import Foundation

enum TextAlignment: String {
    case left = "left"
    case center = "center"
    case right = "right"
}

class AmongUsModel {
    var id: String
    var createdDate: Date
    var position: Float
    var backgoundImage: String
    var icon: String
    var text: String
    var fontSize: Float
    var font: String
    var textColor: UInt
    var iconDirection: Bool // True: clock, false: reverse clock
    var textAlignment: TextAlignment
    
    init(realmEntity: AmongUsEntity) {
        self.id = realmEntity.id
        self.createdDate = realmEntity.createdDate
        self.position = realmEntity.position
        self.backgoundImage = realmEntity.backgoundImage
        self.icon = realmEntity.icon
        self.text = realmEntity.text
        self.fontSize = realmEntity.fontSize
        self.font = realmEntity.font
        self.textColor = UInt(realmEntity.textColor) ?? 0x000000
        self.iconDirection = realmEntity.iconDirection
        self.textAlignment = TextAlignment.init(rawValue: realmEntity.textAlignment) ?? .left
    }
    
    init(id: String,
         position: Float,
         backgoundImage: String,
         icon: String,
         text: String,
         fontSize: Float,
         font: String,
         textColor: UInt,
         iconDirection: Bool,
         textAlignment: TextAlignment) {
        self.id = id
        self.backgoundImage = backgoundImage
        self.position = position
        self.icon = icon
        self.text = text
        self.fontSize = fontSize
        self.font = font
        self.textColor = textColor
        self.iconDirection = iconDirection
        self.textAlignment = textAlignment
        self.createdDate = Date()
    }
    
    func wallpaperPath() -> String {
        let wallpaperPath = FileManager.wallpaperPath()
        let path = "\(wallpaperPath)/\(self.id).\(self.fileExtension())"
        return path
    }
    
    func fileExtension() -> String {
        return "jpg"
    }
    
    func realmEntity() -> AmongUsEntity {
        let entity = AmongUsEntity()
        entity.id = self.id
        entity.createdDate = self.createdDate
        entity.position = self.position
        entity.backgoundImage = self.backgoundImage
        entity.icon = self.icon
        entity.text = self.text
        entity.fontSize = self.fontSize
        entity.font = self.font
        entity.textColor = String(self.textColor)
        entity.iconDirection = self.iconDirection
        return entity
    }
    
    func getLocalWallpaperURL() -> URL {
        return FileManager.wallpaperURL().appendingPathComponent("\(id).\(fileExtension())")
    }
    
    func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? AmongUsModel else {
            return false
        }
        
        return object.id == self.id
    }
}

class AmongUsDao: RealmDao {
    func saveWallpaper(_ object: AmongUsEntity) {
        try? addObject(object)
    }
    
    func deleteWallpaper(_ object: AmongUsEntity) {
        let predicate = NSPredicate(format: "id == \"\(object.id)\"")
        guard let listWallpaper = try? self.objects(type: AmongUsEntity.self, predicate: predicate) else {
            return
        }
        
        try? self.deleteObjects(Array(listWallpaper))
    }
    
    func deleteWallpapers(_ ids: [String]) {
        let predicate = NSPredicate(format: "id IN %@", ids)
        try? self.deleteObjects(type: AmongUsEntity.self, predicate: predicate)
    }
    
    func getWallpaper() -> [AmongUsModel] {
        guard let results = try? self.objects(type: AmongUsEntity.self) else {
            return []
        }
        
        let objects = results.map({AmongUsModel.init(realmEntity: $0)})
        
        return objects.sorted { (lhs, rhs) -> Bool in
            return lhs.createdDate > rhs.createdDate
        }
    }
}
