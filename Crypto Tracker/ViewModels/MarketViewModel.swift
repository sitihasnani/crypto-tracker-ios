//
//  MarketViewModel.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

@MainActor
final class MarketViewModel: ObservableObject {
    @Published private(set) var coins: [CoinModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isOffline: Bool = false

    private let service: CryptoServicing
    private let cacheFile = "market_data.json"

    init(service: CryptoServicing = CryptoService()) {
        self.service = service

        //load data offline
        if let cached: [CoinModel] = DiskCache.shared.load([CoinModel].self, from: cacheFile){
            self.coins = cached
        }
        Task {
            await refresh(force: false)
        }

    }

    func refresh(force: Bool = false) async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil

        do {
            let data = try await service.fetchMarket(page: 1, perPage: 50)
            self.coins = data
            DiskCache.shared.save(data, to: cacheFile)
        } catch {
            self.isOffline = true
            if let cached: [CoinModel] = DiskCache.shared.load([CoinModel].self, from: cacheFile) {
                self.coins = cached
            }
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
//            self.showError = true
//            print("❌ Error set in refresh: \(self.errorMessage ?? "nil")")
        }

        isLoading = false
    }






}

