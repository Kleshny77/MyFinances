//
//  TransactionsListViewModel.swift
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
        didSet(old) {
            if period.start > period.end {
                period.end = period.start
                return
            }
            if period.end < period.start {
                period.start = period.end
                return
            }
            Task { await loadInitialTransactions() }
        }
    }
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isPaginating = false
    @Published private(set) var allDataLoaded = false

    private let service = TransactionsService()
    private let direction: Direction
    private let pageSize = 20

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()

    init(direction: Direction,
         period: HistoryPeriod = HistoryPeriod(
            start: Calendar.current
                .date(byAdding: .month, value: -1, to: .now)!
                .startOfDay,
            end: .now.endOfDay
         )
    ) {
        self.direction = direction
        self.period = period
        Task { await loadInitialTransactions() }
    }

    var totalAmount: Decimal {
        transactions.reduce(0) { $0 + $1.amount }
    }

    var formattedTotal: String {
        totalAmount.formattedSmart
    }

    var formattedStart: String {
        Self.dateFormatter.string(from: period.start)
    }

    var formattedEnd: String {
        Self.dateFormatter.string(from: period.end)
    }

    func loadInitialTransactions() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        transactions = []
        allDataLoaded = false
        do {
            let items = try await service.fetchTransactions(
                from: period.start.startOfDay,
                to: period.end.endOfDay,
            )
            transactions = items
            allDataLoaded = items.count < pageSize
        } catch {
            transactions = []
        }
    }

    func loadMoreTransactions() async {
        guard !isLoading, !isPaginating, !allDataLoaded else { return }
        isPaginating = true
        defer { isPaginating = false }
        do {
            let items = try await service.fetchTransactions(
                from: period.start.startOfDay,
                to: period.end.endOfDay,
            )
            if items.isEmpty {
                allDataLoaded = true
            } else {
                transactions.append(contentsOf: items)
            }
        } catch {
        }
    }
}
