//
//  NetworkRetryManager.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 24/08/2025.
//
final class NetworkRetryManager {
    static let shared = NetworkRetryManager()

    private var pendingRequests: [() async -> Void] = []

    func add(_ request: @escaping () async -> Void) {
        pendingRequests.append(request)
    }

    func retryAll() {
        let requests = pendingRequests
        pendingRequests.removeAll()

        Task {
            for request in requests {
                await request()
            }
        }
    }
}

