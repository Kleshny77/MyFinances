import UIKit

final class SumCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let valueLabel = UILabel()
    static let reuseIdentifier = "SumCell"
    func configure(sum: String) {
        configureNameLabel()
        configureValueLabel(sum: sum)
    }
    private func configureNameLabel() {
        nameLabel.text = "Сумма"
        nameLabel.font = .systemFont(ofSize: 17, weight: .regular)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    private func configureValueLabel(sum: String) {
        valueLabel.text = sum
        valueLabel.font = .systemFont(ofSize: 17, weight: .regular)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
} 