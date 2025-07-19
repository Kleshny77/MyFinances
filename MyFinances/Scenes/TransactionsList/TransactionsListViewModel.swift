//
//  TransactionsListViewModel.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

@MainActor
final class TransactionsListViewModel: ObservableObject {
    // MARK: – Published
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var sortOption: SortOption = .date {
        didSet { transactions = applySort(transactions) }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case date   = "По дате"
        case amount = "По сумме"
        var id: Self { self }
    }
    
    // MARK: – Services
    private let service = TransactionsService.create()
    let direction: Direction
    let accountId: Int
    
    // MARK: – Init
    init(direction: Direction, accountId: Int) {
        self.direction = direction
        self.accountId = accountId
    }
    
    // MARK: – Data
    func loadTransactions() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let start = Date.startOfToday
        let end = Date.endOfToday ?? Date()
        let startStr = DateFormatterFactory.yyyyMMdd.string(from: start)
        let endStr = DateFormatterFactory.yyyyMMdd.string(from: end)
        let responses = try await service.fetchTransactions(accountId: accountId, startDate: startStr, endDate: endStr)
        let all = responses.map { Transaction.fromAPI($0) }
        let filtered = all.filter {
            direction == .income ? $0.category.isIncome : !$0.category.isIncome
        }
        transactions = applySort(filtered)
    }
    
    // MARK: – Helpers
    private func applySort(_ list: [Transaction]) -> [Transaction] {
        switch sortOption {
        case .date:   return list.sorted { $0.transactionDate > $1.transactionDate }
        case .amount: return list.sorted { $0.amount > $1.amount }
        }
    }
    
    var navigationTitle: String {
        direction == .income
        ? TransactionsListConstants.titleIncome
        : TransactionsListConstants.titleOutcome
    }
}
