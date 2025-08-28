//
//  CoinTableViewController.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//
import UIKit
import CoreData

class CoinTableViewController: UITableViewController {
    var coins: [CoinModel] = []
    var didSelect: ((CoinModel) -> Void)?
    var style: CoinTableViewCellStyle = .market
    private var viewModel: MarketViewModel
    private let searchBar = UISearchBar()
    private var frc: NSFetchedResultsController<Favorite>?

    init(viewModel: MarketViewModel, style: CoinTableViewCellStyle) {
        self.viewModel = viewModel
        self.style = style
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(CoinTableViewCell.self, forCellReuseIdentifier:  CoinTableViewCell.identifier)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: PersistenceController.shared.container.viewContext,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
        frc?.delegate = self
        try? frc?.performFetch()

    }

    @objc private func refreshData() {
        Task { await refreshDataAsync() }
    }

    private func refreshDataAsync() async {
        await viewModel.refresh(force: true)
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
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
            if let cell = tableView.cellForRow(at: indexPath) as? CoinTableViewCell {
                        cell.setFavorite(!isFav, animated: true)
            }
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

extension CoinTableViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}