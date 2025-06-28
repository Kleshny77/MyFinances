//
//  TransactionsListViewModel.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

@MainActor
final class TransactionsListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var sortOption: SortOption = .date {
        didSet {
            transactions = applySort(transactions)
        }
    }
    
    enum SortOption: String, CaseIterable, Identifiable {
        case date = "По дате"
        case amount = "По сумме"
        
        var id: Self { self }
    }
    
    private let service = TransactionsService()
    let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }
        do {
            guard let end = Date.endOfToday else { return }
            let all = try await service.fetchTransactions(
                from: .startOfToday,
                to: end
            )
            let filtered = all.filter {
                direction == .income
                ? $0.category.isIncome
                : !$0.category.isIncome
            }
            transactions = applySort(filtered)
        } catch {
            transactions = []
        }
    }
    
    private func applySort(_ list: [Transaction]) -> [Transaction] {
        switch sortOption {
        case .date:
            return list.sorted { $0.transactionDate > $1.transactionDate }
        case .amount:
            return list.sorted { $0.amount > $1.amount }
        }
    }
    
    var navigationTitle: String {
        direction == .income ? TransactionsListConstants.titleIncome : TransactionsListConstants.titleOutcome
    }
}
