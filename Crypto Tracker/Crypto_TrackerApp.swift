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
    @StateObject private var favoritesVM = FavoritesViewModel()
    var body: some Scene {
        WindowGroup {
            MainView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(themeManager)
            .environmentObject(favoritesVM)
            .preferredColorScheme(themeManager.selectedScheme)
            .onAppear {
                NotificationManager.shared.requestAuthorization()
            }
        }
    }
}
