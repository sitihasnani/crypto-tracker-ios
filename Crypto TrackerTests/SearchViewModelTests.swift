//
//  SearchViewModelTests.swift
//  Crypto TrackerTests
//
//  Created by Siti Hasnani on 26/08/2025.
//

import XCTest
@testable import Crypto_Tracker
import Combine

final class SearchViewModelTests: XCTestCase {

    var viewModel: SearchViewModel!
    var mockService: MockCryptoService!

    @MainActor
    override func setUpWithError() throws {
        mockService = MockCryptoService()
        viewModel = SearchViewModel(service: mockService)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
    }

    @MainActor
    func testSearchOnlineSuccess() async throws {
        // Given
        let expectedCoins = [CoinModel(id: "ethereum", name: "Ethereum", symbol: "eth", image: nil, currentPrice: 3000, marketCap: nil, priceChangePercentage24h: nil)]
        mockService.mockCoins = expectedCoins

        // When
        viewModel.searchText = "eth"
        // Give debounce time to pass
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.id, "ethereum")
        XCTAssertTrue(viewModel.searchHistory.contains("eth"))
    }

    @MainActor
    func testSearchOfflineFallbackToLocal() async throws {
        // Given
        let localCoins = [CoinModel(id: "bitcoin", name: "Bitcoin", symbol: "btc", image: nil, currentPrice: 50000, marketCap: nil, priceChangePercentage24h: nil)]
        viewModel.setAllCoins(localCoins)
        mockService.shouldThrowError = true // Simulate offline by making API fail
        mockService.mockError = APIError.networkError(URLError(.notConnectedToInternet))

        // When
        viewModel.searchText = "bit"
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.id, "bitcoin")
        XCTAssertFalse(viewModel.searchHistory.contains("bit")) // Local search should not add to history
    }

    @MainActor
    func testSearchOnlineFailureFallbackToLocal() async throws {
        // Given
        let localCoins = [CoinModel(id: "litecoin", name: "Litecoin", symbol: "ltc", image: nil, currentPrice: 100, marketCap: nil, priceChangePercentage24h: nil)]
        viewModel.setAllCoins(localCoins)
        mockService.shouldThrowError = true
        mockService.mockError = APIError.badStatusCode(404)

        // When
        viewModel.searchText = "lite"
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.searchResults.count, 1)
        XCTAssertEqual(viewModel.searchResults.first?.id, "litecoin")
        XCTAssertFalse(viewModel.searchHistory.contains("lite")) // Failed online search should not add to history
    }

    @MainActor
    func testSearchHistoryManagement() async throws {
        // When
        viewModel.searchText = "btc"
        try await Task.sleep(nanoseconds: 1_000_000_000)
        viewModel.searchText = "eth"
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Then
        XCTAssertEqual(viewModel.searchHistory.count, 2)
        XCTAssertEqual(viewModel.searchHistory.first, "eth")
        XCTAssertEqual(viewModel.searchHistory.last, "btc")

        // When: Clear history
        viewModel.clearSearchHistory()

        // Then
        XCTAssertTrue(viewModel.searchHistory.isEmpty)
    }
}
