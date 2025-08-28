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
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @State private var showingSetAlertSheet = false
    @State private var targetPrice: String = ""
    @State private var alertType: Int = 0 // 0 for above, 1 for below
    @State private var showAlert = false
    @State private var alertMessage = ""

    init(id: String, name: String) {
        self.id = id
        self.name = name
        _vm = StateObject(wrappedValue: CoinDetailViewModel(id: id))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                if let error = vm.errorMessage {
                    ErrorView(message: error) {
                        Task { await vm.refresh() }
                    }
                } else if vm.isLoading {
                    LoadingOverlay()
                        .frame(maxWidth: .infinity, minHeight: 120)
                } else if let d = vm.detail {
                    VStack(alignment: .leading, spacing: 16) {
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
                            Button(action: {
                                showingSetAlertSheet = true
                            }) {
                                Label("Set Alert", systemImage: favoritesVM.isPriceAlertSet(coinID: id) ? "bell.fill" : "bell")
                            }
                        }

                        Divider()

                        if let desc = d.description?.en, !desc.isEmpty {
                            Text(desc.replacingOccurrences(of: "\r\n", with: "\n"))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("No data available.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle(name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task { await vm.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Test Price") {
                    if let currentPrice = vm.detail?.usdPrice {
                        vm.setTestPrice(price: currentPrice * 1.1)
                    }
                }
            }
        }

        .refreshable { await vm.refresh() }
        .onAppear {
            isFavorite = FavoritesManager.shared.isFavorite(id: id)
        }
        .sheet(isPresented: $showingSetAlertSheet) {
            PriceAlertSheet(
                coinID: id,
                coinName: name,
                currentPrice: vm.detail?.usdPrice,
                showingSetAlertSheet: $showingSetAlertSheet,
                targetPrice: $targetPrice,
                alertType: $alertType,
                onShowAlert: { message in
                    alertMessage = message
                    showAlert = true
                }
            )
        }
        .alert("Price Alert!", isPresented: $showAlert) {
            Button("OK") { } 
        } message: {
            Text(alertMessage)
        }
        .onChange(of: vm.detail) { _, _ in 
            checkPriceAlerts()
        }
    }


    private func checkPriceAlerts() {
        print("checkPriceAlerts called")
        guard let currentPrice = vm.detail?.usdPrice else { 
            print("Current price is nil, returning.")
            return 
        }
        print("Current price: \(currentPrice)")

        for alert in favoritesVM.priceAlerts.filter({ $0.coinID == id }) {
            print("Checking alert for coinID: \(String(describing: alert.coinID)), targetPrice: \(alert.targetPrice), alertType: \(alert.alertType)")
            if alert.alertType == 0 && currentPrice >= alert.targetPrice { // Above
                print("Above alert triggered!")
                alertMessage = "\(name) has reached or exceeded \(alert.targetPrice.asCurrency)! Current price: \(currentPrice.asCurrency)"
                showAlert = true
                NotificationManager.shared.scheduleNotification(title: "Price Alert for \(name)", body: alertMessage, id: alert.id ?? UUID().uuidString)
                favoritesVM.removePriceAlert(alert: alert) // Remove alert after triggering
            } else if alert.alertType == 1 && currentPrice <= alert.targetPrice { // Below
                print("Below alert triggered!")
                alertMessage = "\(name) has fallen to or below \(alert.targetPrice.asCurrency)! Current price: \(currentPrice.asCurrency)"
                showAlert = true
                NotificationManager.shared.scheduleNotification(title: "Price Alert for \(name)", body: alertMessage, id: alert.id ?? UUID().uuidString)
                favoritesVM.removePriceAlert(alert: alert) // Remove alert after triggering
            }
        }
    }

}
