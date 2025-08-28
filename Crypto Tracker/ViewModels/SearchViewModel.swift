//
//  SearchViewModel.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 26/08/2025.
//

import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var searchResults: [CoinModel] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published private(set) var searchHistory: [String] = []

    private let service: CryptoServicing
    private var allCoins: [CoinModel] = []
    private var cancellables = Set<AnyCancellable>()
    private let searchHistoryKey = "search_history"

    init(service: CryptoServicing = CryptoService()) {
        self.service = service
        loadSearchHistory()
        
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                if searchText.isEmpty {
                    self.searchResults = []
                    self.errorMessage = nil
                } else {
                    Task { await self.search(query: searchText) }
                }
            }
            .store(in: &cancellables)
    }

    func setAllCoins(_ coins: [CoinModel]) {
        self.allCoins = coins
    }

    func search(query: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let coins = try await service.searchCoins(query: query)
            self.searchResults = coins
            addSearchToHistory(query)
        } catch {
            self.errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            // Fallback to local search if API call fails
            performLocalSearch(query: query)
        }
        isLoading = false
    }

    private func performLocalSearch(query: String) {
        self.searchResults = allCoins.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.symbol.localizedCaseInsensitiveContains(query)
        }
    }

    private func loadSearchHistory() {
        if let history = UserDefaults.standard.stringArray(forKey: searchHistoryKey) {
            searchHistory = history
        }
    }

    func addSearchToHistory(_ query: String) {
        var currentHistory = searchHistory.filter { $0 != query }
        currentHistory.insert(query, at: 0)
        if currentHistory.count > 5 { // Limit history to 5 items
            currentHistory = Array(currentHistory.prefix(5))
        }
        searchHistory = currentHistory
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
    }

    func clearSearchHistory() {
        searchHistory = []
        UserDefaults.standard.removeObject(forKey: searchHistoryKey)
    }
}
