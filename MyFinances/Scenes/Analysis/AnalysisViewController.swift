import UIKit

final class AnalysisViewController: UIViewController {
    private enum Section: Int, CaseIterable {
        case periodAndSum, operations
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    var periodStart: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
    var periodEnd:   Date = .now {
        didSet {
            if periodEnd < periodStart {
                periodStart = periodEnd
            }
        }
    }

    private var operations: [Transaction] = []
    private var service: TransactionsService?
    private let accountId: Int

    init(accountId: Int) {
        self.accountId = accountId
        super.init(nibName: nil, bundle: nil)
        
        Task {
            do {
                try await initializeService()
            } catch {
                service = TransactionsService.create()
            }
        }
    }
    
    private func initializeService() async throws {
        service = await TransactionsService.createWithLocalStorage()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Анализ"
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        reloadData()
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource      = self
        tableView.delegate        = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle  = .none

        tableView.register(PeriodCell.self,
                           forCellReuseIdentifier: PeriodCell.reuseID)
        tableView.register(OperationCell.self,
                           forCellReuseIdentifier: OperationCell.reuseID)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func reloadData() {
        Task {
            let startOfDay = Calendar.current.startOfDay(for: periodStart)
            let endOfDay = Calendar.current.date(
                bySettingHour: 23, minute: 59, second: 59,
                of: periodEnd
            )!
            do {
                guard let service = service else {
                    let fallbackService = TransactionsService.create()
                    let startStr = DateFormatterFactory.yyyyMMdd.string(from: startOfDay)
                    let endStr = DateFormatterFactory.yyyyMMdd.string(from: endOfDay)
                    let responses = try await fallbackService.fetchTransactions(accountId: accountId, startDate: startStr, endDate: endStr)
                    operations = responses.map { Transaction.fromAPI($0) }
                    return
                }
                
                let startStr = DateFormatterFactory.yyyyMMdd.string(from: startOfDay)
                let endStr = DateFormatterFactory.yyyyMMdd.string(from: endOfDay)
                let responses = try await service.fetchTransactions(accountId: accountId, startDate: startStr, endDate: endStr)
                operations = responses.map { Transaction.fromAPI($0) }
            } catch {
                operations = []
            }
            await MainActor.run {
                tableView.reloadData()
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return f.string(from: date)
    }

    private func formattedSum() -> String {
        let total = operations.reduce(0) { $0 + $1.amount }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = " "
        f.maximumFractionDigits = 0
        return (f.string(from: total as NSNumber) ?? "0") + " ₽"
    }

    private func showDatePicker(isStart: Bool) {
        let vc = DatePickerVC(
            title: isStart ? "Начало периода" : "Конец периода",
            initial: isStart ? periodStart : periodEnd
        ) { [weak self] newDate in
            guard let self = self else { return }
            if isStart { self.periodStart = newDate }
            else       { self.periodEnd   = newDate }
            self.reloadData()
        }
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
    }
}

// MARK: — UITableViewDataSource & Delegate

extension AnalysisViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .periodAndSum: return 3
        case .operations:   return operations.count
        }
    }

    func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        switch Section(rawValue: section)! {
        case .operations: return "ОПЕРАЦИИ"
        default:          return nil
        }
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        guard section == Section.operations.rawValue,
              let header = view as? UITableViewHeaderFooterView
        else { return }
        header.textLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        header.textLabel?.textColor = .secondaryLabel
        header.textLabel?.text = header.textLabel?.text?.uppercased()
        header.contentView.backgroundColor = .systemGroupedBackground
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .periodAndSum:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PeriodCell.reuseID,
                for: indexPath
            ) as! PeriodCell
            switch indexPath.row {
            case 0:
                cell.configure(title: "Период: начало", value: formattedDate(periodStart))
                cell.onTap = { self.showDatePicker(isStart: true) }
            case 1:
                cell.configure(title: "Период: конец", value: formattedDate(periodEnd))
                cell.onTap = { self.showDatePicker(isStart: false) }
            default:
                cell.configure(title: "Сумма", value: formattedSum())
                cell.onTap = nil
            }
            return cell

        case .operations:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: OperationCell.reuseID,
                for: indexPath
            ) as! OperationCell
            let total = operations.reduce(0) { $0 + $1.amount }
            cell.configure(with: operations[indexPath.row], total: total)
            return cell
        }
    }
}

// MARK: — PeriodCell

final class PeriodCell: UITableViewCell {
    static let reuseID = String(describing: PeriodCell.self)
    var onTap: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) { super.init(coder: coder) }

    func configure(title: String, value: String) {
        textLabel?.text       = title
        detailTextLabel?.text = value
        accessoryType         = onTap == nil ? .none : .disclosureIndicator
        selectionStyle        = onTap == nil ? .none : .default
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        onTap?()
    }
}

// MARK: — OperationCell

final class OperationCell: UITableViewCell {
    static let reuseID = String(describing: OperationCell.self)

    private let container      = UIView()
    private let iconLabel      = UILabel()
    private let titleLabel     = UILabel()
    private let subtitleLabel  = UILabel()
    private let percentLabel   = UILabel()
    private let amountLabel    = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor      = .clear
        contentView.backgroundColor = .clear

        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false

        iconLabel.font = .systemFont(ofSize: 24)
        container.addSubview(iconLabel)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 17)
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        container.addSubview(textStack)
        textStack.translatesAutoresizingMaskIntoConstraints = false

        percentLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        amountLabel.font  = .systemFont(ofSize: 14)
        amountLabel.textColor = .secondaryLabel
        let rightStack = UIStackView(arrangedSubviews: [percentLabel, amountLabel])
        rightStack.axis      = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing   = 2
        container.addSubview(rightStack)
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            iconLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            iconLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            rightStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            rightStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            textStack.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -8),
        ])

        selectionStyle = .none
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    func configure(with op: Transaction, total: Decimal) {
        iconLabel.text    = String(op.category.emoji)
        titleLabel.text   = op.category.name
        subtitleLabel.text = op.comment ?? ""

        let pct: Int = total > 0
            ? NSDecimalNumber(decimal: op.amount)
                .dividing(by: NSDecimalNumber(decimal: total))
                .multiplying(by: 100)
                .intValue
            : 0
        percentLabel.text = "\(pct)%"

        let fmt = NumberFormatter()
        fmt.numberStyle       = .decimal
        fmt.groupingSeparator = " "
        let amt = fmt.string(from: op.amount as NSDecimalNumber) ?? "0"
        amountLabel.text = "\(amt) ₽"
    }
}
