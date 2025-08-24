//
//  FavoritesViewModel.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//
import CoreData
import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var favorites: [Favorite] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchFavorites()
    }

    func fetchFavorites() {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        do {
            favorites = try context.fetch(request)
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }

    func isFavorite(id: String) -> Bool {
        favorites.contains(where: { $0.id == id })
    }

    func toggleFavorite(coin: CoinModel) {
        if let fav = favorites.first(where: { $0.id == coin.id }) {
            context.delete(fav)
        } else {
            let fav = Favorite(context: context)
            fav.id = coin.id
            fav.name = coin.name
            fav.symbol = coin.symbol
            fav.imageUrl = coin.image
            fav.dateAdded = Date()
        }
        save()
    }

    private func save() {
        do {
            try context.save()
            fetchFavorites()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}


