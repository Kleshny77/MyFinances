//
//  HistoryViewModel.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

struct HistoryPeriod {
    var start: Date
    var end: Date
}

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var startDate: Date {
        didSet {
            if startDate > endDate {
                endDate = startDate
            }
            updatePeriod()
        }
    }

    @Published var endDate: Date {
        didSet {
            if endDate < startDate {
                startDate = endDate
            }
            updatePeriod()
        }
    }

    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isLoading = false

    @Published var sortOption: TransactionsListViewModel.SortOption = .date {
        didSet {
            transactions = applySort(transactions)
        }
    }

    private let service = TransactionsService.create()
    let accountId: Int
    let direction: Direction?

    init(
        direction: Direction?,
        accountId: Int,
        initialPeriod: HistoryPeriod = HistoryPeriod(
            start: Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now,
            end: Date.now
        )
    ) {
        self.direction = direction
        self.accountId = accountId
        self.startDate = initialPeriod.start
        self.endDate = initialPeriod.end

        Task {
            do {
                try await loadTransactions()
            } catch {
                // Ошибка при инициализации - транзакции будут загружены позже
            }
        }
    }

    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var formattedTotal: String {
        totalAmount.formattedSmart
    }
    
    private func applySort(_ list: [Transaction]) -> [Transaction] {
        switch sortOption {
        case .date:
            return list.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return list.sorted { $0.amount > $1.amount }
        }
    }

    func loadTransactions() async throws {
        isLoading = true
        defer { isLoading = false }

        let startStr = DateFormatterFactory.yyyyMMdd.string(from: Date.startOfDay(for: startDate))
        let endStr = DateFormatterFactory.yyyyMMdd.string(from: Date.endOfDay(for: endDate))
        let responses = try await service.fetchTransactions(accountId: accountId, startDate: startStr, endDate: endStr)
        let allTransactions = responses.map { Transaction.fromAPI($0) }

        var filtered = allTransactions
        if let direction = direction {
            filtered = allTransactions.filter {
                direction == .income ? $0.category.isIncome : !$0.category.isIncome
            }
        }

        transactions = applySort(filtered)
    }

    private func updatePeriod() {
        Task { 
            do {
                try await loadTransactions()
            } catch {
                // Ошибка при обновлении периода: транзакции будут загружены позже
            }
        }
    }
}
