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
    private var service: TransactionsService?
    let direction: Direction
    let accountId: Int
    
    // MARK: – Init
    init(direction: Direction, accountId: Int) {
        self.direction = direction
        self.accountId = accountId
        
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
    
    // MARK: – Data
    func loadTransactions() async throws {
        guard let service = service else {
            let fallbackService = TransactionsService.create()
            let start = Date.startOfToday
            let end = Date.endOfToday ?? Date()
            let startStr = DateFormatterFactory.yyyyMMdd.string(from: start)
            let endStr = DateFormatterFactory.yyyyMMdd.string(from: end)
            let responses = try await fallbackService.fetchTransactions(accountId: accountId, startDate: startStr, endDate: endStr)
            let all = responses.map { Transaction.fromAPI($0) }
            let filtered = all.filter {
                direction == .income ? $0.category.isIncome : !$0.category.isIncome
            }
            transactions = applySort(filtered)
            return
        }
        
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
