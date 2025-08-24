//
//  DiskCache.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation
import UIKit

final class DiskCache{
    static let shared = DiskCache()
    private init(){}

    private var cacheURL: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    func save<T: Encodable>(_ value: T, to filename: String){
        do {
            let url = cacheURL.appendingPathComponent(filename)
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
            print("Saved cache to: \(url.path)")

        } catch {
            print("Error saving data to disk: \(error)")
        }
    }

    func load<T: Decodable>(_ type: T.Type, from filename: String) -> T? {
        let url = cacheURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func imageURL(for filename: String) -> URL {
            cacheURL.appendingPathComponent(filename)
        }

    func save(image: UIImage, forKey key: String) {
        let url = imageURL(for: key)
        guard let data = image.pngData() else { return }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving image to disk: \(error)")
        }
    }

    func loadImage(forKey key: String) -> UIImage? {
        let url = imageURL(for: key)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
