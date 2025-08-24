//
//  AppCoordinator.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 24/08/2025.
//
import Combine

class AppCoordinator {
    private var monitor = NetworkMonitor.shared
    private var cancellable: AnyCancellable?

    init() {
        cancellable = monitor.$isConnected.sink { isConnected in
            if isConnected {
                NetworkRetryManager.shared.retryAll()
            }
        }
    }
}


