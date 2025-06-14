//
//  Cases.swift
//  MyFinances
//
//  Created by Артём on 13.06.2025.
//

import Foundation

// MARK: - Поля в объекте Transaction
enum TransactionCases: String, JSONKey, CaseIterable {
    case id, account, category, amount, transactionDate, comment, createdAt, updatedAt
}

// MARK: - Поля в объекте BankAccountCases
enum BankAccountCases: String, JSONKey {
    case id, userId, name, balance, currency, createdAt, updatedAt
}

// MARK: - Поля в объекте CategoryCases
enum CategoryCases: String, JSONKey {
    case id, name, emoji, isIncome
}
