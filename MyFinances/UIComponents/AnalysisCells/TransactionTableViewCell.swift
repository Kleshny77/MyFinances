import UIKit

final class TransactionTableViewCell: UITableViewCell {
    private let emojiBackgroundView = UIView()
    private let emojiLabel = UILabel()
    private let nameLabel = UILabel()
    private let commentLabel = UILabel()
    private let sumLabel = UILabel()
    private let percentLabel = UILabel()
    private let leftStack = UIStackView()
    private let rightStack = UIStackView()
    private let mainStack = UIStackView()
    static let reuseIdentifier = "TransactionTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupUI() {
        // --- Emoji background ---
        emojiBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.2) ?? UIColor(red: 0.439, green: 0.898, blue: 0.545, alpha: 0.2)
        emojiBackgroundView.layer.cornerRadius = CellsConstants.circleSize / 2
        emojiBackgroundView.layer.masksToBounds = true
        emojiBackgroundView.widthAnchor.constraint(equalToConstant: CellsConstants.circleSize).isActive = true
        emojiBackgroundView.heightAnchor.constraint(equalToConstant: CellsConstants.circleSize).isActive = true

        emojiLabel.font = .systemFont(ofSize: CellsConstants.emojiFontSize, weight: .bold)
        emojiLabel.textAlignment = .center
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiBackgroundView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor)
        ])

        nameLabel.font = .systemFont(ofSize: 17, weight: .regular)
        commentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        commentLabel.textColor = .secondaryLabel
        commentLabel.numberOfLines = 1
        sumLabel.font = .systemFont(ofSize: 17, weight: .regular)
        sumLabel.textAlignment = .right
        percentLabel.font = .systemFont(ofSize: 14, weight: .regular)
        percentLabel.textColor = .secondaryLabel
        percentLabel.textAlignment = .right

        leftStack.axis = .vertical
        leftStack.spacing = 2
        leftStack.alignment = .leading
        leftStack.addArrangedSubview(nameLabel)
        leftStack.addArrangedSubview(commentLabel)

        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .trailing
        rightStack.addArrangedSubview(sumLabel)
        rightStack.addArrangedSubview(percentLabel)

        mainStack.axis = .horizontal
        mainStack.spacing = 12
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(emojiBackgroundView)
        mainStack.addArrangedSubview(leftStack)
        mainStack.addArrangedSubview(rightStack)
        contentView.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            rightStack.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
    }

    func configure(transaction: Transaction, sum: String, percent: String) {
        emojiLabel.text = String(transaction.category.emoji)
        nameLabel.text = transaction.category.name
        commentLabel.text = transaction.comment
        sumLabel.text = sum
        percentLabel.text = percent
        commentLabel.isHidden = (transaction.comment ?? "").isEmpty
    }
} 