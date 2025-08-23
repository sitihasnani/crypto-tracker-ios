//
//  MarketListView.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import SwiftUI

struct MarketListView: View {
    @StateObject private var vm = MarketViewModel()
    @Environment(\.managedObjectContext) private var context
        @FetchRequest(
            sortDescriptors: []
        ) private var favorites: FetchedResults<Favorite>
    @State private var showOnlyFavorites = false
    @State private var searchText = ""
    @State private var selectedCoin: CoinModel?

    var body: some View {
        NavigationStack {
            VStack {
                CoinTableView(coins: filteredCoins, style: .market) { coin in
                    selectedCoin = coin
                }
            }
            .navigationTitle("Crypto Prices")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search coin")
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(id: coin.id, name: coin.name)
            }
        }
    }

    private var filteredCoins: [CoinModel] {
        var coins = vm.coins
        if showOnlyFavorites {
            let favIds = Set(favorites.map { $0.id ?? "" })
            coins = coins.filter { favIds.contains($0.id) }
        }
        if !searchText.isEmpty {
            coins = coins.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
        return coins
    }
}



