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
            Category(id: 1, name: "Продукты",     emoji: "🛒", isIncome: false),
            Category(id: 2, name: "Зарплата",     emoji: "💼", isIncome: true),
            Category(id: 3, name: "Транспорт",    emoji: "🚕", isIncome: false),
            Category(id: 4, name: "Подарки",      emoji: "🎁", isIncome: true),
            Category(id: 5, name: "Цели",         emoji: "🏦", isIncome: false),
            Category(id: 6, name: "Инвестиции",   emoji: "📈", isIncome: true),
            Category(id: 7, name: "Кафе",         emoji: "☕️", isIncome: false),
            Category(id: 8, name: "Фриланс",      emoji: "🧑‍💻", isIncome: true),
            Category(id: 9, name: "Путешествия",  emoji: "✈️", isIncome: false),
            Category(id: 10, name: "Премия",      emoji: "🏅", isIncome: true)
        ]
        
        let accounts: [BankAccount] = [
            BankAccount(
                id: 1,
                userId: 1,
                name: "Тинькофф Дебетовая",
                balance: 12000,
                currency: "RUB",
                createdAt: baseDate,
                updatedAt: baseDate
            )
        ]
        
        let totalCount = 100
        let todayCount = 40
        var result: [Transaction] = []
        
        for i in 0..<totalCount {
            let category = categories.randomElement()!
            let account  = accounts.randomElement()!
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
                    return calendar.date(
                        byAdding: .second,
                        value: Int.random(in: 0..<(24*60*60)),
                        to: baseDate
                    )!
                } else {
                    let daysAgo   = Int.random(in: 1...30)
                    let randomSec = Int.random(in: 0..<(24*60*60))
                    let date      = calendar.date(byAdding: .day, value: -daysAgo, to: baseDate)!
                    return calendar.date(byAdding: .second, value: randomSec, to: date)!
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
        
        return result.sorted { $0.transactionDate > $1.transactionDate }
    }()
    
    init() {
        try? cache.loadTransactions(fileName: fileName)
        cache.bootstrapIfNeeded(with: mockTransactions)
        try? cache.saveTransactions(fileName: fileName)
    }
    
    func fetchTransactions(from start: Date, to end: Date) async throws -> [Transaction] {
        try? cache.loadTransactions(fileName: fileName)
        return cache.transactions
            .values
            .filter { start ... end ~= $0.transactionDate }
            .sorted { $0.transactionDate < $1.transactionDate }
    }
    
    func createTransaction(transaction: Transaction) async throws {
        try cache.add(transaction: transaction)
        try cache.saveTransactions(fileName: fileName)
    }
    
    func updateTransaction(transaction: Transaction) async throws {
        do {
            try cache.delete(id: transaction.id)
        } catch FileError.transactionNotFound {
        }
        try cache.add(transaction: transaction)
        try cache.saveTransactions(fileName: fileName)
    }
    
    func deleteTransaction(id: Int) async throws {
        do {
            try cache.delete(id: id)
        } catch FileError.transactionNotFound { }
        try cache.saveTransactions(fileName: fileName)
    }
}
