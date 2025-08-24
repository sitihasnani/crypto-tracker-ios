//
//  Crypto_TrackerApp.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//

import SwiftUI

@main
struct Crypto_TrackerApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var themeManager = ThemeManager.shared
    var body: some Scene {
        WindowGroup {
            TabView {
                MarketListView()
                    .tabItem {
                        Label("Market", systemImage: "bitcoinsign.circle")
                    }

                FavoritesView()
                    .tabItem {
                        Label("Favourites", systemImage: "heart.fill")
                    }
                }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.selectedScheme)
        }
    }
}
