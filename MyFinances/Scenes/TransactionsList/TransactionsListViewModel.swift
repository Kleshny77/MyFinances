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
    private let service = TransactionsService()
    let direction: Direction
    
    // MARK: – Init
    init(direction: Direction) { self.direction = direction }
    
    // MARK: – Data
    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        do {
            guard let end = Date.endOfToday else { return }
            let all = try await service.fetchTransactions(from: .startOfToday, to: end)
            let filtered = all.filter {
                direction == .income ? $0.category.isIncome : !$0.category.isIncome
            }
            transactions = applySort(filtered)
        } catch {
            transactions = []
        }
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
