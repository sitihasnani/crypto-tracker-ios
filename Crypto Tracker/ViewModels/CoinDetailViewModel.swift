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
            DiskCache.shared.save(coinDetail, to: "detail_\(id).json")
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
        }
        isLoading = false
    }


}
