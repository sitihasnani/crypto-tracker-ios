//
//  CoinTableView.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//
import SwiftUI

struct CoinTableView: UIViewControllerRepresentable {
    var coins: [CoinModel]
    var style: CoinTableViewCellStyle = .market
    var didSelect: (CoinModel) -> Void
    @ObservedObject var viewModel: MarketViewModel

    func makeUIViewController(context: Context) -> CoinTableViewController {
        let vc = CoinTableViewController(viewModel: viewModel, style: style)
        vc.coins = coins
        vc.didSelect = didSelect
        return vc
    }

    func updateUIViewController(_ uiViewController: CoinTableViewController, context: Context) {
        uiViewController.coins = coins
        uiViewController.tableView.reloadData()
    }
}


