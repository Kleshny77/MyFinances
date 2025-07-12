import UIKit

final class AnalysisViewController: UIViewController {
    //MARK: - Variables
    private let vm: AnalysisViewModel
    private let dateAndSumSection: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private let actionMenuButton: UIButton = UIButton()
    
    //MARK: - Lifecycle
    init(startDate: Date, endDate: Date, service: TransactionsService, direction: Direction) {
        vm = AnalysisViewModel(service: service, direction: direction)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Анализ"
        Task {
            try await vm.loadData(startDate: Date().startOfMonth, endDate: Date().endOfMonth)
            vm.setUpCategories()
            dateAndSumSection.reloadData()
        }
        configureUI()
    }
    
    //MARK: - SetUp UI
    private func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        configureDateAndSumSection()
    }
    
    private func configureDateAndSumSection() {
        dateAndSumSection.register(DateTableCell.self, forCellReuseIdentifier: DateTableCell.reuseIdentifier)
        dateAndSumSection.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        dateAndSumSection.register(SumCell.self, forCellReuseIdentifier: SumCell.reuseIdentifier)
        dateAndSumSection.register(SortCell.self, forCellReuseIdentifier: SortCell.reuseIdentifier)
        dateAndSumSection.dataSource = self
        dateAndSumSection.delegate = self
        
        view.addSubview(dateAndSumSection)
        dateAndSumSection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateAndSumSection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateAndSumSection.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dateAndSumSection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dateAndSumSection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension AnalysisViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1: return vm.categories.count
        default: return 4
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return "Операции"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: SumCell.reuseIdentifier, for: indexPath)
                guard let sumCell = cell as? SumCell else { return cell }
                sumCell.configure(sum: vm.stringSumAll())
                sumCell.selectionStyle = .none
                return sumCell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: SortCell.reuseIdentifier, for: indexPath)
                guard let sortCell = cell as? SortCell else { return cell }
                sortCell.configure()
                sortCell.menuDelegate = self
                sortCell.selectionStyle = .none
                return sortCell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: DateTableCell.reuseIdentifier, for: indexPath)
                guard let dateCell = cell as? DateTableCell else { return cell }
                dateCell.configure(border: indexPath.row == 0 ? .start : .end)
                dateCell.dateDelegate = self
                dateCell.selectionStyle = .none
                return dateCell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath)
            guard let categoryCell = cell as? CategoryTableViewCell else { return cell }
            let category = vm.categories[indexPath.row]
            let sum = vm.stringSum(for: category)
            let percent = vm.stringPercent(for: category)
            categoryCell.configure(category: category, sum: sum, percent: percent)
            categoryCell.accessoryType = .disclosureIndicator
            categoryCell.selectionStyle = .none
            return categoryCell
        }
    }
}

extension AnalysisViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1: return 60
        default: return 44
        }
    }
}

extension AnalysisViewController: MenuDelegate {
    func menu(_ sortingType: SortingType) {
        vm.sort(by: sortingType)
        dateAndSumSection.reloadSections([1], with: .none)
    }
}

extension AnalysisViewController: DateDelegate {
    func datePicker(cell: DateTableCell, newDate: Date) {
        let border = cell.border
        
        let otherCellIndex: IndexPath = {
            let idx = dateAndSumSection.indexPath(for: cell)!
            return IndexPath(row: idx.row == 0 ? 1 : 0, section: idx.section)
        }()
        
        if let otherCell = dateAndSumSection.cellForRow(at: otherCellIndex) as? DateTableCell {
            if border == .start && newDate > otherCell.getDate() {
                otherCell.setDate(newDate)
            } else if border == .end && newDate < otherCell.getDate() {
                otherCell.setDate(newDate)
            }
        } else {
            dateAndSumSection.reloadRows(at: [otherCellIndex], with: .none)
        }
        
        let startCell = dateAndSumSection.cellForRow(at: IndexPath(row: 0, section: 0)) as! DateTableCell
        let endCell = dateAndSumSection.cellForRow(at: IndexPath(row: 1, section: 0)) as! DateTableCell
        Task {
            try await vm.loadData(startDate: startCell.getDate(), endDate: endCell.getDate())
            vm.setUpCategories()
            UIView.performWithoutAnimation {
                dateAndSumSection.reloadSections([1], with: .none)
                dateAndSumSection.layoutIfNeeded()
                dateAndSumSection.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .none)
            }
        }
    }
}
