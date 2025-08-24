//
//  ImageCache.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 24/08/2025.
//
import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private let memoryCache = NSCache<NSString, UIImage>()

    func image(forKey key: String) -> UIImage? {
        if let mem = memoryCache.object(forKey: key as NSString) { return mem }
        if let disk = DiskCache.shared.loadImage(forKey: key) {
            memoryCache.setObject(disk, forKey: key as NSString)
            return disk
        }
        return nil
    }

    func setImage(_ image: UIImage, forKey key: String) {
        memoryCache.setObject(image, forKey: key as NSString)
        DiskCache.shared.save(image: image, forKey: key)
    }
}


