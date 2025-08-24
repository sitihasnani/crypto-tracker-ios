//
//  CoinTableViewCell.swift
//  Crypto Tracker
//
//  Created by Siti Hasnani on 23/08/2025.
//
import UIKit

class CoinTableViewCell: UITableViewCell {
    static let identifier = "CoinTableViewCell"

    private let coinImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 6
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel = UILabel()
    private let symbolLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()
    private let favoriteIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart.fill"))
        iv.tintColor = .systemRed
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private var style: CoinTableViewCellStyle = .market

    func setFavorite(_ isFavorite: Bool, animated: Bool) {
        guard style == .market else { return }

        if animated {
            UIView.transition(with: favoriteIcon,
                                duration: 0.25,
                                options: .transitionCrossDissolve,
                                animations: {
                                    self.favoriteIcon.isHidden = !isFavorite
                                })
            } else {
                favoriteIcon.isHidden = !isFavorite
            }
        }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, favoriteIcon])
        nameStack.axis = .horizontal
        nameStack.spacing = 4

        let leftStack = UIStackView(arrangedSubviews: [nameStack, symbolLabel])
        leftStack.axis = .vertical
        leftStack.alignment = .leading
        leftStack.spacing = 2

        let rightStack = UIStackView(arrangedSubviews: [priceLabel, changeLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 2

        let mainStack = UIStackView(arrangedSubviews: [coinImageView, leftStack, UIView(), rightStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(mainStack)
        NSLayoutConstraint.activate([
            coinImageView.widthAnchor.constraint(equalToConstant: 32),
            coinImageView.heightAnchor.constraint(equalToConstant: 32),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        symbolLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        symbolLabel.textColor = .secondaryLabel
        priceLabel.font = UIFont.boldSystemFont(ofSize: 14)
        changeLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with coin: CoinModel, style: CoinTableViewCellStyle, isFavorite: Bool) {
        nameLabel.text = coin.name
        symbolLabel.text = coin.symbol.uppercased()
        priceLabel.text = coin.displayPrice
        changeLabel.text = coin.displayChange
        changeLabel.textColor = (coin.priceChangePercentage24h ?? 0) >= 0 ? .systemGreen : .systemRed

        switch style {
            case .market:
                priceLabel.text = coin.displayPrice
                changeLabel.text = coin.displayChange
                changeLabel.textColor = (coin.priceChangePercentage24h ?? 0) >= 0 ? .systemGreen : .systemRed
                favoriteIcon.isHidden = !isFavorite
            case .favorites:
                priceLabel.text = coin.displayPrice
                changeLabel.text = coin.displayChange
                changeLabel.textColor = (coin.priceChangePercentage24h ?? 0) >= 0 ? .systemGreen : .systemRed
                favoriteIcon.isHidden = true
            }

        if let urlStr = coin.image {
            if let cached = ImageCache.shared.image(forKey: urlStr) {
                coinImageView.image = cached
            } else if let url = URL(string: urlStr) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    if let data = data, let img = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.coinImageView.image = img
                            ImageCache.shared.setImage(img, forKey: urlStr)
                        }
                    }
                }.resume()
            }
        }
        else {
            coinImageView.image = nil
        }
    }
}

