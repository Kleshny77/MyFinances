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
    
    // Моковые транзакции
    private let mockTransactions: [Transaction] = {
        let baseDate = Date.startOfToday
        let calendar = Calendar.current
        let categories: [Category] = [
            Category(id: 1, name: "Продукты", emoji: "🛒", isIncome: false),
            Category(id: 2, name: "Зарплата", emoji: "💼", isIncome: true),
            Category(id: 3, name: "Транспорт", emoji: "🚕", isIncome: false),
            Category(id: 4, name: "Подарки", emoji: "🎁", isIncome: true),
            Category(id: 5, name: "Цели", emoji: "🏦", isIncome: false),
            Category(id: 6, name: "Инвестиции", emoji: "📈", isIncome: true),
            Category(id: 7, name: "Кафе", emoji: "☕️", isIncome: false),
            Category(id: 8, name: "Фриланс", emoji: "🧑‍💻", isIncome: true),
            Category(id: 9, name: "Путешествия", emoji: "✈️", isIncome: false),
            Category(id: 10, name: "Премия", emoji: "🏅", isIncome: true)
        ]
        let accounts: [BankAccount] = [
            BankAccount(id: 1, userId: 1, name: "Тинькофф Дебетовая", balance: 12000, currency: "RUB", createdAt: baseDate, updatedAt: baseDate),
            BankAccount(id: 2, userId: 1, name: "СберКарта", balance: 5000, currency: "RUB", createdAt: baseDate, updatedAt: baseDate),
            BankAccount(id: 3, userId: 1, name: "USD Savings", balance: 300, currency: "USD", createdAt: baseDate, updatedAt: baseDate),
            BankAccount(id: 4, userId: 1, name: "EUR Card", balance: 150, currency: "EUR", createdAt: baseDate, updatedAt: baseDate)
        ]
        let n = 50
        let secondsInDay = 24 * 60 * 60
        let interval = secondsInDay / n
        return (0..<n).map { i in
            let transactionDate = calendar.date(byAdding: .second, value: i * interval, to: baseDate)!
            let category = categories[i % categories.count]
            let account = accounts[i % accounts.count]
            let isIncome = category.isIncome
            let amount: Decimal = {
                if isIncome {
                    return Decimal(500 + (i % 7) * 100 + (i * 13) % 250)
                } else {
                    return Decimal(50 + (i % 5) * 70 + (i * 17) % 120)
                }
            }()
            return Transaction(
                id: i,
                account: account,
                category: category,
                amount: amount,
                transactionDate: transactionDate,
//                comment: "Транзакция #\(i) — \(category.name)",
                createdAt: transactionDate,
                updatedAt: transactionDate
            )
        }
    }()
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        // try cache.loadTransactions(fileName: fileName)
        // let transactions = cache.transactions.values
        // Используем моковые данные вместо файла
        let transactions = mockTransactions
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
