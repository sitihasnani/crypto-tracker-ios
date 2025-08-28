//
//  FavoritesViewModelTests.swift
//  Crypto TrackerTests
//
//  Created by Siti Hasnani on 26/08/2025.
//

import XCTest
import CoreData
@testable import Crypto_Tracker

final class FavoritesViewModelTests: XCTestCase {

    var viewModel: FavoritesViewModel!
    var mockPersistentContainer: NSPersistentContainer!

    @MainActor
    override func setUpWithError() throws {
        mockPersistentContainer = NSPersistentContainer(name: "CryptoTrackerModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType // Use in-memory store for testing
        mockPersistentContainer.persistentStoreDescriptions = [description]
        mockPersistentContainer.loadPersistentStores { (description, error) in
            XCTAssertNil(error)
        }
        viewModel = FavoritesViewModel(context: mockPersistentContainer.viewContext)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockPersistentContainer = nil
    }

    @MainActor
    func testToggleFavorite() throws {
        // Given
        let coin = CoinModel(id: "bitcoin", name: "Bitcoin", symbol: "btc", image: nil, currentPrice: 50000, marketCap: nil, priceChangePercentage24h: nil)

        // When: Add favorite
        viewModel.toggleFavorite(coin: coin)

        // Then
        XCTAssertTrue(viewModel.isFavorite(id: "bitcoin"))
        XCTAssertEqual(viewModel.favorites.count, 1)

        // When: Remove favorite
        viewModel.toggleFavorite(coin: coin)

        // Then
        XCTAssertFalse(viewModel.isFavorite(id: "bitcoin"))
        XCTAssertTrue(viewModel.favorites.isEmpty)
    }

    @MainActor
    func testAddPriceAlert() throws {
        // Given
        let coinID = "ethereum"
        let targetPrice = 3000.0
        let alertType = 0 // Above

        // When
        viewModel.addPriceAlert(coinID: coinID, targetPrice: targetPrice, alertType: alertType)

        // Then
        XCTAssertEqual(viewModel.priceAlerts.count, 1)
        XCTAssertEqual(viewModel.priceAlerts.first?.coinID, coinID)
        XCTAssertEqual(viewModel.priceAlerts.first?.targetPrice, targetPrice)
        XCTAssertEqual(viewModel.priceAlerts.first?.alertType, Int16(alertType))
        XCTAssertTrue(viewModel.isPriceAlertSet(coinID: coinID))
    }

    @MainActor
    func testRemovePriceAlert() throws {
        // Given
        let coinID = "litecoin"
        let targetPrice = 100.0
        let alertType = 1 // Below
        viewModel.addPriceAlert(coinID: coinID, targetPrice: targetPrice, alertType: alertType)
        let alertToRemove = try XCTUnwrap(viewModel.priceAlerts.first)

        // When
        viewModel.removePriceAlert(alert: alertToRemove)

        // Then
        XCTAssertTrue(viewModel.priceAlerts.isEmpty)
        XCTAssertFalse(viewModel.isPriceAlertSet(coinID: coinID))
    }
}
