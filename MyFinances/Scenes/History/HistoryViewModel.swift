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
    @Published var period: HistoryPeriod {
        didSet(oldValue) {
            var periodChanged = false
            // Если изменилось начало периода и оказалось позже конца
            if period.start != oldValue.start && period.start > period.end {
                period.end = period.start
                periodChanged = true
            // Если изменился конец периода и он оказался раньше начала
            } else if period.end != oldValue.end && period.end < period.start {
                period.start = period.end
                periodChanged = true
            }

            if periodChanged {
                // didSet вызовется снова, так что просто выходим
                return
            }
            
            Task { await loadTransactions() }
        }
    }
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isLoading = false

    private let service = TransactionsService()
    private let direction: Direction
    
    init(
        direction: Direction,
        period: HistoryPeriod = HistoryPeriod(
            start: Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now,
            end: Date.now
        )
    ) {
        self.direction = direction
        self.period = period
        Task { await loadTransactions() }
    }

    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var formattedTotal: String {
        totalAmount.formattedSmart
    }

    var formattedStart: String {
        Self.mediumDateFormatter.string(from: period.start)
    }

    var formattedEnd: String {
        Self.mediumDateFormatter.string(from: period.end)
    }

    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let allTransactions = try await service.fetchTransactions(
                from: startOfDay(for: period.start),
                to: endOfDay(for: period.end)
            )
            
            transactions = allTransactions.filter {
                direction == .income ? $0.category.isIncome : !$0.category.isIncome
            }
            .sorted { $0.transactionDate > $1.transactionDate }
            
        } catch {
            transactions = []
        }
    }
    
    // MARK: - Date Helpers
    
    private func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    private func endOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay(for: date)) ?? date
        return calendar.date(byAdding: .second, value: -1, to: startOfTomorrow) ?? date
    }

    private static let mediumDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
}
