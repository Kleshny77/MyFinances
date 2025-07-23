import UIKit

protocol DateDelegate: AnyObject {
    func datePicker(cell: DateTableCell, newDate: Date)
}

enum Border {
    case start, end
}

final class DateTableCell: UITableViewCell {
    private let label = UILabel()
    private let picker = UIDatePicker()
    private(set) var border: Border?
    weak var dateDelegate: DateDelegate?
    static let reuseIdentifier = "DateTableCell"

    func configure(border: Border, date: Date) {
        self.border = border
        configureLabel(text: border == .start ? "Период: начало" : "Период: конец")
        configurePicker(date: date)
    }
    private func configureLabel(text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    private func configurePicker(date: Date) {
        picker.date = date
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = .systemBlue
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
        contentView.addSubview(picker)
        NSLayoutConstraint.activate([
            picker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            picker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    func setDate(_ date: Date) { picker.date = date }
    func getDate() -> Date { picker.date }
    @objc private func dateDidChange() {
        dateDelegate?.datePicker(cell: self, newDate: picker.date)
    }
} 