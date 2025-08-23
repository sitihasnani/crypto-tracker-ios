//
//  CoinModel.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//

import Foundation

struct CoinModel: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let symbol: String
    let image: String?
    let currentPrice: Double?
    let marketCap: Double?
    let priceChangePercentage24h: Double?

    enum CodingKeys: String, CodingKey {
            case id, symbol, name, image
            case currentPrice = "current_price"
            case marketCap = "market_cap"
            case priceChangePercentage24h = "price_change_percentage_24h"
        }

    var displayPrice: String {
        guard let currentPrice = currentPrice else {
            return "N/A"
        }
        return String(format: "%.2f", currentPrice)
    }

    var displayChange: String {
        guard let priceChangePercentage24h = priceChangePercentage24h else {
            return "N/A"
        }
        return String(format: "%.2f%%", priceChangePercentage24h)
    }
}
