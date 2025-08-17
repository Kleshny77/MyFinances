//
//  AnalysisViewModel.swift
//  MyFinances
//
//  Created by Артём on 10.07.2025.
//

import Foundation

protocol TransactionsServiceProtocol {
    func fetchTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [TransactionResponse]
    func createTransaction(request: TransactionRequest) async throws
    func updateTransaction(id: Int, request: TransactionRequest) async throws
    func deleteTransaction(id: Int) async throws
}

final class AnalysisViewModel: ObservableObject {
    private let service: TransactionsServiceProtocol
    private let accountId: Int
    private let direction: Direction
    @Published var transactions: [Transaction] = []
    @Published var startDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @Published var endDate: Date = .now
    @Published var sortingType: SortingType = .date
    
    init(accountId: Int, direction: Direction, service: TransactionsServiceProtocol) {
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
            transactions = all.filtered(by: direction).sorted(by: sortingType == .date ? .date : .amount)
        } catch {
            transactions = []
        }
    }
    
    func stringPercent(for transaction: Transaction) -> String {
        transaction.amount.formattedPercent(of: transactions.totalAmount)
    }
    func stringSum(for transaction: Transaction) -> String {
        "\(transaction.amount.formattedSmart) ₽"
    }
    func stringSumAll() -> String {
        "\(transactions.totalAmount.formattedSmart) ₽"
    }
} 
