//
//  TransactionsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

struct TransactionsService {
    private let cache = TransactionsFileCache()
    private let fileName = "transactions.json"
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        try cache.loadTransactions(fileName: fileName)
        let transactions = cache.transactions.values
            .filter { startDate ... endDate ~= $0.transactionDate }
            .sorted { $0.transactionDate < $1.transactionDate }
        
        return transactions
    }
    
    func createTransaction(transaction: Transaction) async throws {
        try cache.add(transaction: transaction)
        try cache.saveTransactions(fileName: fileName)
    }
    
    // Ооочень простой мок, потому что пока непонятно что должен делать update.
    func updateTransaction(transaction: Transaction) async throws {
        try cache.delete(id: transaction.id)
        try cache.add(transaction: transaction)
        try cache.saveTransactions(fileName: fileName)
    }
    
    func deleteTransaction(id: Int) async throws {
        try cache.delete(id: id)
        try cache.saveTransactions(fileName: fileName)
    }
}
