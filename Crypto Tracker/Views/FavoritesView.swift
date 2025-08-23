//
//  FavoritesView.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//
import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Favorite.name, ascending: true)]
    ) private var favorites: FetchedResults<Favorite>

    @StateObject private var marketVM = MarketViewModel()
    @State private var selectedCoin: CoinModel?

    var body: some View {
        NavigationStack {
            CoinTableView(
                coins: favoriteCoins, style: .favorites
            ) { coin in
                selectedCoin = coin
            }
            .navigationTitle("Favourites")
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(id: coin.id, name: coin.name)
            }
            .refreshable {
                await marketVM.refresh()
            }
        }
        .onAppear {
            Task { await marketVM.refresh() }
        }
    }

    private var favoriteCoins: [CoinModel] {
        favorites.compactMap { fav in
            guard let id = fav.id else { return nil }
            if let marketCoin = marketVM.coins.first(where: { $0.id == id }) {
                return marketCoin
            } else {
                // fallback if market data not loaded yet
                return CoinModel(
                    id: id,
                    name: fav.name ?? "",
                    symbol: fav.symbol ?? "",
                    image: fav.imageUrl,
                    currentPrice: nil,
                    marketCap: nil,
                    priceChangePercentage24h: nil
                )
            }
        }
    }
}








