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

    func makeUIViewController(context: Context) -> CoinTableViewController {
        let vc = CoinTableViewController()
        vc.coins = coins
        vc.didSelect = didSelect
        vc.style = style
        return vc
    }

    func updateUIViewController(_ uiViewController: CoinTableViewController, context: Context) {
        uiViewController.coins = coins
        uiViewController.tableView.reloadData()
    }
}


