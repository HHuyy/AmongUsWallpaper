//
//  FileManager.swift
//  AmongUsWallpaper
//
//  Created by Le Toan on 11/1/20.
//

import Foundation

extension FileManager {
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }

    static func documentURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }

    static func wallpaperURL() -> URL {
        let path = self.wallpaperPath()
        return URL(fileURLWithPath: path)
    }
    
    static func wallpaperPath() -> String {
        return "\(NSTemporaryDirectory())wallpaper_path"
    }

    static func createWallpaperDirIfNeeded() {
        var isDirectoryOutput: ObjCBool = false
        let pointer = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        pointer.initialize(from: &isDirectoryOutput, count: 1)

        if FileManager.default.fileExists(atPath: self.wallpaperPath(), isDirectory: pointer) == false ||
            isDirectoryOutput.boolValue == false {
            try? FileManager.default.createDirectory(at: self.wallpaperURL(), withIntermediateDirectories: true, attributes: nil)
        }
    }
}
