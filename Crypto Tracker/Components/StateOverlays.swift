//
//  StateOverlays.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import SwiftUI

struct LoadingOverlay: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
            Text(message).font(.footnote).multilineTextAlignment(.center)
            Button("Retry", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}
