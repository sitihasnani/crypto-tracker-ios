//
//  FavoritesManager.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//

import CoreData

final class FavoritesManager {
    static let shared = FavoritesManager()
    private init() {}

    var context: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    func addFavorite(coin: CoinModel) {
        let fav = Favorite(context: context)
        fav.id = coin.id
        fav.name = coin.name
        fav.symbol = coin.symbol
        fav.imageUrl = coin.image
        fav.dateAdded = Date()

        saveContext()
    }

    func removeFavorite(id: String) {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)

        if let result = try? context.fetch(request).first {
            context.delete(result)
            saveContext()
        }
    }

    func isFavorite(id: String) -> Bool {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        return (try? context.count(for: request)) ?? 0 > 0
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("❌ Failed to save favorite: \(error)")
        }
    }
}


