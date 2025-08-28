//
//  ThemeManager.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 24/08/2025.
//
import SwiftUI

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    private init() {}

    @Published var selectedScheme: ColorScheme? = nil 
}



