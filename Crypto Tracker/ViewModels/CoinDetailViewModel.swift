//
//  CoinDetailViewModel.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

@MainActor
final class CoinDetailViewModel: ObservableObject {
    @Published private(set) var detail: CoinDetailsModel?
    @Published private(set) var isLoading = false
    @Published var errorMessage: String? = nil

    private let service: CryptoServicing
    private let id: String

    init (
        id: String,
        service: CryptoServicing = CryptoService())
    {
        self.id = id
        self.service = service

        if let cached: CoinDetailsModel = DiskCache.shared.load(CoinDetailsModel.self, from: "detail_\(id).json"){
            self.detail = cached
        }
        Task{ await refresh()}
    }

    func refresh() async {
        if isLoading { return }
        isLoading = true
        errorMessage = nil
        do {
            let coinDetail = try await service.fetchDetail(id: id)
            self.detail = coinDetail
            if (try? JSONEncoder().encode(coinDetail)) != nil {
                DiskCache.shared.save(coinDetail, to: "detail_\(id).json")
            }
        } catch {
            if detail == nil {
                if let cached: CoinDetailsModel = DiskCache.shared.load(CoinDetailsModel.self, from: "detail_\(id).json") {
                    self.detail = cached
                }
            }
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription

        }
        isLoading = false
    }

    // For testing notification purposes only
    func setTestPrice(price: Double) {
        if let currentDetail = detail {
            var newCurrentPrice = currentDetail.market_data?.current_price ?? [:]
            newCurrentPrice["usd"] = price

            let newMarketData = CoinDetailsModel.MarketData(
                current_price: newCurrentPrice,
                market_cap: currentDetail.market_data?.market_cap,
                price_change_percentage_24h: currentDetail.market_data?.price_change_percentage_24h,
                high_24h: currentDetail.market_data?.high_24h,
                low_24h: currentDetail.market_data?.low_24h,
                total_volume: currentDetail.market_data?.total_volume
            )
            let newDetail = CoinDetailsModel(
                id: currentDetail.id,
                symbol: currentDetail.symbol,
                name: currentDetail.name,
                image: currentDetail.image,
                hashing_algorithm: currentDetail.hashing_algorithm,
                description: currentDetail.description,
                market_data: newMarketData
            )
            detail = newDetail
        }
    }


}
