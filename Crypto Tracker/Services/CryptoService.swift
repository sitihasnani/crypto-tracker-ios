//
//  CryptoService.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

protocol CryptoServicing {
    func fetchMarket(page: Int, perPage: Int) async throws -> [CoinModel]
    func fetchDetail(id: String) async throws -> CoinDetailsModel
    func searchCoins(query: String) async throws -> [CoinModel]

}

final class CryptoService: CryptoServicing {
    private let api = APIClient()
    private let cacheKeyMarket = "cached_market"
    private let cacheKeyDetailsPrefix = "cached_detail_"

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func fetchMarket(page: Int = 1, perPage: Int = 50) async throws -> [CoinModel] {
        let query: [URLQueryItem] = [
            .init(name: "vs_currency", value: "usd"),
            .init(name: "order", value: "market_cap_desc"),
            .init(name: "per_page", value: "\(perPage)"),
            .init(name: "page", value: "\(page)")
        ]
        let coins: [CoinModel] = try await api.get("/coins/markets", query: query)

        if let data = try? encoder.encode(coins) {
            UserDefaults.standard.set(data, forKey: cacheKeyMarket)
        }

        return coins
    }

    func fetchDetail(id: String) async throws -> CoinDetailsModel {
        let query: [URLQueryItem] = [
            .init(name: "localization", value: "false"),
            .init(name: "market_data", value: "true")
        ]

        do {
            let details: CoinDetailsModel = try await api.get("/coins/\(id)", query: query)

            if let data = try? encoder.encode(details) {
                UserDefaults.standard.set(data, forKey: cacheKeyDetailsPrefix + id)
            }

            return details
        } catch {
                // Fallback to cache if offline
            if let cached = UserDefaults.standard.data(forKey: cacheKeyDetailsPrefix + id),
            let details = try? decoder.decode(CoinDetailsModel.self, from: cached) {
                return details
            }
            throw error
            }
        }

    func searchCoins(query: String) async throws -> [CoinModel] {
        let queryItem: [URLQueryItem] = [
            .init(name: "query", value: query)
        ]
        let searchResponse: CoinSearchResponse = try await api.get("/search", query: queryItem)
        return searchResponse.coins
    }
}
