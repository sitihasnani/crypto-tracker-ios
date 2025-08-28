//
//  SkeletonRowView.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 26/08/2025.
//

import SwiftUI

struct SkeletonRowView: View {
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .frame(width: 32, height: 32)
                .cornerRadius(6)
                .opacity(0.3)

            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .frame(width: 100, height: 20)
                    .opacity(0.3)
                Rectangle()
                    .frame(width: 50, height: 15)
                    .opacity(0.3)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Rectangle()
                    .frame(width: 80, height: 20)
                    .opacity(0.3)
                Rectangle()
                    .frame(width: 60, height: 15)
                    .opacity(0.3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}