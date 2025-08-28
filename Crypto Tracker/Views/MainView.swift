//
//  MainView.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 26/08/2025.
//

import SwiftUI

struct MainView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if selectedTab == 0 {
                    MarketListView()
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing)))
                } else {
                    FavoritesView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                }
            }
            .animation(.easeInOut, value: selectedTab)

            HStack {
                Button(action: { selectedTab = 0 }) {
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Market")
                    }
                }
                .foregroundColor(selectedTab == 0 ? .accentColor : .secondary)
                .frame(maxWidth: .infinity)

                Button(action: { selectedTab = 1 }) {
                    VStack {
                        Image(systemName: "heart.fill")
                        Text("Favorites")
                    }
                }
                .foregroundColor(selectedTab == 1 ? .accentColor : .secondary)
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 8)
            .background(Color(.systemGray6))
        }
    }
}
