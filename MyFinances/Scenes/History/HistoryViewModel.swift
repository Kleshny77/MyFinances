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

    private let service = TransactionsService()
    let direction: Direction?

    init(
        direction: Direction?,
        initialPeriod: HistoryPeriod = HistoryPeriod(
            start: Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now,
            end: Date.now
        )
    ) {
        self.direction = direction
        self.startDate = initialPeriod.start
        self.endDate = initialPeriod.end

        Task { await loadTransactions() }
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

    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allTransactions = try await service.fetchTransactions(
                from: startOfDay(for: startDate),
                to: endOfDay(for: endDate)
            )

            var filtered = allTransactions
            if let direction = direction {
                filtered = allTransactions.filter {
                    direction == .income ? $0.category.isIncome : !$0.category.isIncome
                }
            }

            transactions = applySort(filtered)
        } catch {
            transactions = []
        }
    }

    private func updatePeriod() {
        Task { await loadTransactions() }
    }

    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func endOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay(for: date)) ?? date
        return calendar.date(byAdding: .second, value: -1, to: startOfTomorrow) ?? date
    }
}
