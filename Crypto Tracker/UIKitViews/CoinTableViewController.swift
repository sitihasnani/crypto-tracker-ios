//
//  CoinTableViewController.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//
import UIKit

class CoinTableViewController: UITableViewController {
    var coins: [CoinModel] = []
    var didSelect: ((CoinModel) -> Void)?
    var style: CoinTableViewCellStyle = .market
    private let viewModel = MarketViewModel()
    private let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CoinTableViewCell.self, forCellReuseIdentifier:  CoinTableViewCell.identifier)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        Task {
            await viewModel.refresh(force: false)
            tableView.reloadData()
        }
    }

    @objc private func refreshData() {
        Task {
            await viewModel.refresh(force: true)
            refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let coin = coins[indexPath.row]
        let isFav = FavoritesManager.shared.isFavorite(id: coin.id)

        let action = UIContextualAction(style: .normal, title: "") { _, _, completion in
            if isFav {
                FavoritesManager.shared.removeFavorite(id: coin.id)
            } else {
                FavoritesManager.shared.addFavorite(coin: coin)
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
            completion(true)
        }

        action.image = UIImage(systemName: isFav ? "heart.slash" : "heart")
        action.backgroundColor = .systemPink

        return UISwipeActionsConfiguration(actions: [action])
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CoinTableViewCell.identifier, for: indexPath) as? CoinTableViewCell else {
            return UITableViewCell()
        }
        let coin = coins[indexPath.row]
        cell.configure(with: coin,style: style, isFavorite: FavoritesManager.shared.isFavorite(id: coin.id))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = coins[indexPath.row]
        didSelect?(coin)
    }
}

