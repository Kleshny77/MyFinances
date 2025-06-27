//
//  PreviewMocks.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

struct PreviewMocks {
    static let sampleTransaction: Transaction = {
        sampleTransactions[0]
    }()
    
    static let sampleTransactions: [Transaction] = [
            Transaction(
                id: 1,
                account: BankAccount(
                    id: 1,
                    userId: 1,
                    name: "Тинькофф",
                    balance: 120000.32,
                    currency: "RUB",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                category: Category(
                    id: 1,
                    name: "Продукты",
                    emoji: "🛒",
                    isIncome: false
                ),
                amount: 543.21,
                transactionDate: Date(),
                comment: "Магнит у дома",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 2,
                account: BankAccount(
                    id: 2,
                    userId: 1,
                    name: "Сбер",
                    balance: 75_000,
                    currency: "USD",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                category: Category(
                    id: 2,
                    name: "Путешествия",
                    emoji: "✈️",
                    isIncome: false
                ),
                amount: 1200.30,
                transactionDate: Date(),
                comment: "Билеты на самолёт",
                createdAt: Date(),
                updatedAt: Date()
            ),
            Transaction(
                id: 3,
                account: BankAccount(
                    id: 3,
                    userId: 1,
                    name: "Копилка",
                    balance: 30000.21,
                    currency: "EUR",
                    createdAt: Date(),
                    updatedAt: Date()
                ),
                category: Category(
                    id: 3,
                    name: "Зарплата",
                    emoji: "💰",
                    isIncome: true
                ),
                amount: 3000,
                transactionDate: Date(),
                comment: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
}
