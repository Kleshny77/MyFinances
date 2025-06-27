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
    
    private let mockTransactions: [Transaction] = {
        let calendar = Calendar.current
        let baseDate = Date.startOfToday
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
        ]

        let totalCount = 100
        let todayCount = 40
        var result: [Transaction] = []

        for i in 0..<totalCount {
            let category = categories.randomElement()!
            let account = accounts.randomElement()!
            let isIncome = category.isIncome

            let randomAmount: Decimal = {
                if isIncome {
                    return Decimal(Int.random(in: 400...1200))
                } else {
                    return Decimal(Int.random(in: 50...700))
                }
            }()
            
            let transactionDate: Date = {
                if i < todayCount {
                    return calendar.date(byAdding: .second, value: Int.random(in: 0..<(24 * 60 * 60)), to: baseDate)!
                } else {
                    let daysAgo = Int.random(in: 1...30)
                    let randomTime = Int.random(in: 0..<(24 * 60 * 60))
                    let date = calendar.date(byAdding: .day, value: -daysAgo, to: baseDate)!
                    return calendar.date(byAdding: .second, value: randomTime, to: date)!
                }
            }()
            
            result.append(
                Transaction(
                    id: i,
                    account: account,
                    category: category,
                    amount: randomAmount,
                    transactionDate: transactionDate,
                    createdAt: transactionDate,
                    updatedAt: transactionDate
                )
            )
        }

        return result.sorted(by: { $0.transactionDate > $1.transactionDate })
    }()
    
    func fetchTransactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
//        try cache.loadTransactions(fileName: fileName)
//        let transactions = cache.transactions.values
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
