//
//  Untitled.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import SwiftUI

struct CoinDetailView: View {
    let id: String
    let name: String
    @StateObject private var vm: CoinDetailViewModel
    @State private var isFavorite: Bool = false

    init(id: String, name: String) {
        self.id = id
        self.name = name
        _vm = StateObject(wrappedValue: CoinDetailViewModel(id: id))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let error = vm.errorMessage {
                    ErrorView(message: error) { Task { await vm.refresh() } }
                }

                if let d = vm.detail {
                    VStack(alignment: .leading, spacing: 16) {

                        // Large Icon + Name + Favorite
                        HStack(alignment: .center, spacing: 12) {
                            AsyncImage(url: URL(string: d.image?.large ?? "")) { image in
                                image.resizable()
                                     .scaledToFit()
                                     .frame(width: 60, height: 60)
                            } placeholder: {
                                ProgressView()
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(d.name)
                                    .font(.title)
                                    .bold()
                                Text(d.symbol.uppercased())
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                        }

                        HStack {
                            Text(d.usdPrice.asCurrency)
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                        }

                        if let pct = d.market_data?.price_change_percentage_24h {
                            Text(String(format: "24h: %@%.2f%%", pct >= 0 ? "+" : "", pct))
                                .foregroundColor(pct >= 0 ? .green : .red)
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            if let mc = d.market_data?.market_cap?["usd"] {
                                HStack {
                                    Text("Market Cap")
                                    Spacer()
                                    Text(mc.asCurrency)
                                }
                            }

                            if let vol = d.market_data?.total_volume?["usd"] {
                                HStack {
                                    Text("Volume (24h)")
                                    Spacer()
                                    Text(vol.asCurrency)
                                }
                            }

                            if let high = d.market_data?.high_24h?["usd"],
                               let low = d.market_data?.low_24h?["usd"] {
                                HStack {
                                    Text("24h High / Low")
                                    Spacer()
                                    Text("\(high.asCurrency) / \(low.asCurrency)")
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        Divider()

                        if let desc = d.description?.en, !desc.isEmpty {
                            Text(desc.replacingOccurrences(of: "\r\n", with: "\n"))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                else if vm.isLoading {
                    LoadingOverlay()
                        .frame(maxWidth: .infinity, minHeight: 120)
                }
                else {
                    Text("No data available.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(name)
        .toolbar {
            Button {
                Task { await vm.refresh() }
            } label: {
                Image(systemName: "arrow.clockwise")
            }
        }
        .refreshable { await vm.refresh() }
        .onAppear {
            isFavorite = FavoritesManager.shared.isFavorite(id: id)
        }
    }

}

