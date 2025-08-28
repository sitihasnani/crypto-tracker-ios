//
//  MarketViewModelTests.swift
//  Crypto TrackerTests
//
//  Created by Siti Hasnani on 26/08/2025.
//

import XCTest
@testable import Crypto_Tracker

final class MarketViewModelTests: XCTestCase {

    var viewModel: MarketViewModel!
    var mockService: MockCryptoService!

    @MainActor
    override func setUpWithError() throws {
        mockService = MockCryptoService()
        viewModel = MarketViewModel(service: mockService)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockService = nil
    }

    @MainActor
    func testFetchMarketSuccess() async throws {
        // Given
        let expectedCoins = [CoinModel(id: "bitcoin", name: "Bitcoin", symbol: "btc", image: nil, currentPrice: 50000, marketCap: nil, priceChangePercentage24h: nil)]
        mockService.mockCoins = expectedCoins

        // When
        await viewModel.refresh()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.coins.count, 1)
        XCTAssertEqual(viewModel.coins.first?.id, "bitcoin")
    }

    @MainActor
    func testFetchMarketFailure() async throws {
        // Given
        mockService.shouldThrowError = true
        mockService.mockError = APIError.badStatusCode(500)

        // When
        await viewModel.refresh()

        // Then
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, APIError.badStatusCode(500).localizedDescription)
        XCTAssertTrue(viewModel.coins.isEmpty) // Should be empty if no cached data
    }

    @MainActor
    func testIsLoadingState() async throws {
        // Given
        mockService.mockCoins = [] // Prevent actual data loading

        // When
        let refreshTask = Task { await viewModel.refresh() }

        // Then
        XCTAssertTrue(viewModel.isLoading)
        await refreshTask.value // Wait for refresh to complete
        XCTAssertFalse(viewModel.isLoading)
    }
}

// Mock CryptoService for testing
class MockCryptoService: CryptoServicing {
    var mockCoins: [CoinModel]?
    var mockDetail: CoinDetailsModel?
    var shouldThrowError = false
    var mockError: Error = APIError.unknown

    func fetchMarket(page: Int, perPage: Int) async throws -> [CoinModel] {
        if shouldThrowError {
            throw mockError
        }
        return mockCoins ?? []
    }

    func fetchDetail(id: String) async throws -> CoinDetailsModel {
        if shouldThrowError {
            throw mockError
        }
        guard let detail = mockDetail else {
            throw APIError.unknown
        }
        return detail
    }

    func searchCoins(query: String) async throws -> [CoinModel] {
        if shouldThrowError {
            throw mockError
        }
        return mockCoins ?? []
    }
}
