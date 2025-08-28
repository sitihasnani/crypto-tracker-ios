//
//  MarketListView.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import SwiftUI

struct MarketListView: View {
    @StateObject private var vm = MarketViewModel()
//    @EnvironmentObject var vm: MarketViewModel
    @ObservedObject private var network = NetworkMonitor.shared
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var context
        @FetchRequest(
            sortDescriptors: []
        ) private var favorites: FetchedResults<Favorite>
    @State private var showOnlyFavorites = false
    @State private var searchText = ""
    @State private var selectedCoin: CoinModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !network.isConnected {
                    Text("📡 Offline – showing cached data")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                }
                
                if let error = vm.errorMessage {
                    HStack {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Button("Retry") {
                            Task {
                                await vm.refresh(force: true)
                            }
                        }
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .onAppear {
                            print("❌ Error message is: \(error)")
                        }
                }else {
                    Color.clear
                        .frame(height: 0)
                        .onAppear {
                            print("✅ vm.errorMessage is nil")
                        }
                }

                if vm.isLoading {
                    List {
                        ForEach(0..<10) { _ in
                            SkeletonRowView()
                        }
                    }
                    .listStyle(.plain)
                    .redacted(reason: .placeholder)
                    .shimmering()
                } else {
                    CoinTableView(coins: filteredCoins, style: .market, didSelect: { coin in
                        selectedCoin = coin
                    }, viewModel: vm) // Removed isNetworkConnected
                }
            }

            .navigationTitle("Crypto Prices")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search coin")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Picker("Theme", selection: $themeManager.selectedScheme) {
                        Text("System").tag(ColorScheme?.none)
                        Text("Light").tag(ColorScheme?.some(.light))
                        Text("Dark").tag(ColorScheme?.some(.dark))
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
            }
            .navigationDestination(item: $selectedCoin) { coin in
                CoinDetailView(id: coin.id, name: coin.name)
            }
            .onChange(of: vm.errorMessage) {
                print("📢 errorMessage changed → \(vm.errorMessage ?? "nil")")
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
