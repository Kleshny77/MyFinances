import Foundation

final class AnalysisViewModel {
    private let service: TransactionsService
    private let accountId: Int
    private let direction: Direction
    var transactions: [Transaction] = []
    var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    var endDate: Date = .now
    var sortingType: SortingType = .date
    
    // Теперь сервис должен передаваться снаружи (через контроллер), чтобы избежать MainActor-problem
    init(accountId: Int, direction: Direction, service: TransactionsService) {
        self.accountId = accountId
        self.direction = direction
        self.service = service
    }
    
    @MainActor
    func loadData() async {
        do {
            let startStr = DateFormatterFactory.yyyyMMdd.string(from: startDate)
            let endStr = DateFormatterFactory.yyyyMMdd.string(from: endDate)
            let responses = try await service.fetchTransactions(accountId: accountId, startDate: startStr, endDate: endStr)
            let all = responses.map { Transaction.fromAPI($0) }
            transactions = all.filter { direction == .income ? $0.category.isIncome : !$0.category.isIncome }
            sort()
        } catch {
            transactions = []
        }
    }
    func sort() {
        switch sortingType {
        case .date:
            transactions.sort { (lhs: Transaction, rhs: Transaction) in lhs.transactionDate > rhs.transactionDate }
        case .sum:
            transactions.sort { (lhs: Transaction, rhs: Transaction) in lhs.amount > rhs.amount }
        }
    }
    func stringPercent(for transaction: Transaction) -> String {
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        guard total > 0 else { return "0%" }
        let percent = (transaction.amount / total * 100).rounded(2)
        return "\(percent.cleanValue)%"
    }
    func stringSum(for transaction: Transaction) -> String {
        return "\(transaction.amount.cleanValue) ₽"
    }
    func stringSumAll() -> String {
        let total = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        return "\(total.cleanValue) ₽"
    }
}

private extension Decimal {
    var cleanValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter.string(for: self) ?? "0"
    }
    func rounded(_ scale: Int) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
} 