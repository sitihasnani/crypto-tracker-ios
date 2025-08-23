//
//  CryptoService.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

protocol CryptoServicing {
    func fetchMarket() async throws -> [CoinModel]
    func fetchDetail(id: String) async throws -> CoinDetailsModel

}

final class CryptoService: CryptoServicing {
    private let api = APIClient()

    func fetchMarket() async throws -> [CoinModel] {
        let query: [URLQueryItem] = [
            .init(name: "vs_currency", value: "usd"),
            .init(name: "order", value: "market_cap_desc"),
            .init(name: "per_page", value: "50"),
            .init(name: "page", value: "1")
        ]
        return try await api.get("/coins/markets", query: query)

    }

    func fetchDetail(id: String) async throws -> CoinDetailsModel {
        let query: [URLQueryItem] = [
            .init(name: "localization", value: "false"),
            .init(name: "market_data", value: "true")
        ]
        return try await api.get("/coins/\(id)", query: query)
    }
}
