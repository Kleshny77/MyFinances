import UIKit

protocol MenuDelegate: AnyObject {
    func menu(_ sortingType: SortingType)
}

enum SortingType {
    case date
    case sum
}

final class SortCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let sortButton = UIButton(type: .system)
    weak var menuDelegate: MenuDelegate?
    static let reuseIdentifier = "SortCell"

    func configure(selected: SortingType) {
        configureTitleLabel()
        configureButton(selected: selected)
    }
    private func configureTitleLabel() {
        titleLabel.text = "Сортировка"
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    private func configureButton(selected: SortingType) {
        let menu = UIMenu(children: [
            UIAction(title: "По дате", state: selected == .date ? .on : .off) { [weak self] _ in
                self?.sortButton.setTitle("По дате", for: .normal)
                self?.menuDelegate?.menu(.date)
            },
            UIAction(title: "По сумме", state: selected == .sum ? .on : .off) { [weak self] _ in
                self?.sortButton.setTitle("По сумме", for: .normal)
                self?.menuDelegate?.menu(.sum)
            }
        ])
        sortButton.menu = menu
        sortButton.showsMenuAsPrimaryAction = true
        sortButton.setTitle(selected == .date ? "По дате" : "По сумме", for: .normal)
        sortButton.setTitleColor(.systemBlue, for: .normal)
        sortButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sortButton)
        NSLayoutConstraint.activate([
            sortButton.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            sortButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sortButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
} 