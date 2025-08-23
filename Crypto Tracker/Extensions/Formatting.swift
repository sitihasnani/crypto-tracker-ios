//
//  Formatting.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 22/08/2025.
//
import Foundation

extension Double {
    var asCurrency: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: self)) ?? ""
    }

    var abbreviate: String {
        let num = abs(self)
        let sign = self < 0 ? "-" : ""
        switch num {
        case 1_000_000_000_000...:
            return "\(sign)\(num/1_000_000_000_000).0T"
        case 1_000_000_000...:
            return "\(sign)\(num/1_000_000_000).0B"
        case 1_000_000...:
            return "\(sign)\(num/1_000_000).0M"
        case 1_000...:
            return "\(sign)\(num/1_000).0K"
        default:
            return "\(self)"
        }
    }
}
