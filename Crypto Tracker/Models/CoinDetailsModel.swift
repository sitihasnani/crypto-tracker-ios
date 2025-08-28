//
//  CoinDetailsModel.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

struct CoinDetailsModel: Identifiable, Codable, Equatable {
    let id: String
    let symbol: String
    let name: String
    let image: ImageURLs?
    let hashing_algorithm: String?
    let description: Description?
    let market_data: MarketData?

    struct ImageURLs: Codable, Equatable {
        let thumb: String?
        let small: String?
        let large: String?
    }

    struct Description: Codable, Equatable { let en: String? }
    struct MarketData: Codable, Equatable {
        let current_price: [String: Double]?
        let market_cap: [String: Double]?
        let price_change_percentage_24h: Double?
        let high_24h: [String: Double]?
        let low_24h: [String: Double]?
        let total_volume: [String: Double]?
    }

    var usdPrice: Double { market_data?.current_price?["usd"] ?? 0 }
    var usdMarketCap: Double { market_data?.market_cap?["usd"] ?? 0 }
}


