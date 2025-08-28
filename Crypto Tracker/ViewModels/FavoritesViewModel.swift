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
    @Published private(set) var priceAlerts: [PriceAlert] = []

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        fetchFavorites()
        fetchPriceAlerts()
    }

    func fetchPriceAlerts() {
        let request: NSFetchRequest<PriceAlert> = PriceAlert.fetchRequest()
        do {
            priceAlerts = try context.fetch(request)
        } catch {
            print("Failed to fetch price alerts: \(error)")
        }
    }

    func addPriceAlert(coinID: String, targetPrice: Double, alertType: Int) {
        print("addPriceAlert called for coinID: \(coinID), targetPrice: \(targetPrice), alertType: \(alertType)")
        let alert = PriceAlert(context: context)
        alert.id = UUID().uuidString
        alert.coinID = coinID
        alert.targetPrice = targetPrice
        alert.alertType = Int16(alertType)
        saveAlerts()
    }

    func removePriceAlert(alert: PriceAlert) {
        print("removePriceAlert called for alert ID: \(String(describing: alert.id))")
        context.delete(alert)
        saveAlerts()
    }

    func isPriceAlertSet(coinID: String) -> Bool {
        priceAlerts.contains(where: { $0.coinID == coinID })
    }

    private func saveAlerts() {
        print("saveAlerts called")
        do {
            try context.save()
            print("Context saved successfully")
            fetchPriceAlerts()
        } catch {
            print("Failed to save price alerts: \(error)")
        }
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
        saveFavorites()
    }

    private func saveFavorites() {
        do {
            try context.save()
            fetchFavorites()
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
}


