import UIKit

final class AnalysisViewController: UIViewController {
    private var viewModel: AnalysisViewModel?
    private let accountId: Int
    private let direction: Direction
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    init(accountId: Int, direction: Direction) {
        self.accountId = accountId
        self.direction = direction
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Анализ"
        view.backgroundColor = .systemGroupedBackground
        setupTableView()
        Task { @MainActor in
            let service = await TransactionsService.createWithLocalStorage()
            self.viewModel = AnalysisViewModel(accountId: self.accountId, direction: self.direction, service: service)
            await self.viewModel?.loadData()
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(DateTableCell.self, forCellReuseIdentifier: DateTableCell.reuseIdentifier)
        tableView.register(SortCell.self, forCellReuseIdentifier: SortCell.reuseIdentifier)
        tableView.register(SumCell.self, forCellReuseIdentifier: SumCell.reuseIdentifier)
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.reuseIdentifier)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension AnalysisViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        if section == 0 { return 4 }
        return viewModel.transactions.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 { return "ОПЕРАЦИИ" }
        return nil
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTableCell.reuseIdentifier, for: indexPath) as! DateTableCell
                cell.configure(border: .start, date: viewModel.startDate)
                cell.dateDelegate = self
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTableCell.reuseIdentifier, for: indexPath) as! DateTableCell
                cell.configure(border: .end, date: viewModel.endDate)
                cell.dateDelegate = self
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: SortCell.reuseIdentifier, for: indexPath) as! SortCell
                cell.configure(selected: viewModel.sortingType)
                cell.menuDelegate = self
                cell.selectionStyle = .none
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: SumCell.reuseIdentifier, for: indexPath) as! SumCell
                cell.configure(sum: viewModel.stringSumAll())
                cell.selectionStyle = .none
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.reuseIdentifier, for: indexPath) as! TransactionTableViewCell
            let transaction = viewModel.transactions[indexPath.row]
            cell.configure(transaction: transaction, sum: viewModel.stringSum(for: transaction), percent: viewModel.stringPercent(for: transaction))
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .none
            return cell
        }
    }
}

extension AnalysisViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 { return 60 }
        return 44
    }
}

extension AnalysisViewController: DateDelegate {
    func datePicker(cell: DateTableCell, newDate: Date) {
        guard let viewModel = viewModel else { return }
        if cell.border == .start {
            viewModel.startDate = newDate
            if newDate > viewModel.endDate { viewModel.endDate = newDate }
        } else {
            viewModel.endDate = newDate
            if newDate < viewModel.startDate { viewModel.startDate = newDate }
        }
        Task { @MainActor in
            await viewModel.loadData()
            tableView.reloadData()
        }
    }
}

extension AnalysisViewController: MenuDelegate {
    func menu(_ sortingType: SortingType) {
        guard let viewModel = viewModel else { return }
        viewModel.sortingType = sortingType
        viewModel.transactions = viewModel.transactions.sorted(by: sortingType == .date ? .date : .amount)
        tableView.reloadSections([1], with: .none)
    }
}
