//
//  PriceAlertSheet.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 26/08/2025.
//

import SwiftUI

struct PriceAlertSheet: View {
    let coinID: String
    let coinName: String
    let currentPrice: Double?
    @EnvironmentObject var favoritesVM: FavoritesViewModel
    @Binding var showingSetAlertSheet: Bool
    @Binding var targetPrice: String
    @Binding var alertType: Int
    var onShowAlert: (String) -> Void 
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Price Alert")) {
                    if let currentPrice = currentPrice {
                        HStack {
                            Text("Current Price")
                            Spacer()
                            Text(currentPrice.asCurrency)
                                .bold()
                        }
                    }
                    HStack {
                        Text("Target Price")
                        TextField("Enter price", text: $targetPrice)
                            .keyboardType(.decimalPad)
                    }
                    Picker("Alert When", selection: $alertType) {
                        Text("Above").tag(0)
                        Text("Below").tag(1)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Set Alert for \(coinName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingSetAlertSheet = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Set") {
                        print("Set button tapped in PriceAlertSheet")
                        if let price = Double(targetPrice) {
                            print("Target price converted: \(price)")
                            favoritesVM.addPriceAlert(coinID: coinID, targetPrice: price, alertType: alertType)
                            showingSetAlertSheet = false
                        } else {
                            onShowAlert("Please enter a valid number for the target price.")
                        }
                    }
                }
            }
        }
    }
}
