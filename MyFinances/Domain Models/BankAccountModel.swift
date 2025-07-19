//
//  BankAccountModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

// MARK: - Модель банковского аккаунта
struct BankAccount: Equatable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}

extension BankAccount {
    // MARK: - Перевод сокращений символов в их знаки
    var currencySymbol: String {
        switch currency {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return "?"
        }
    }
}

// MARK: - AccountResponse для API
struct AccountResponse: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
    let incomeStats: [StatItem]?
    let expenseStats: [StatItem]?
    let createdAt: String
    let updatedAt: String
}

struct StatItem: Codable {
    let categoryId: Int
    let categoryName: String
    let emoji: String
    let amount: String
}

struct AccountCreateRequest: Codable {
    let name: String
    let balance: String
    let currency: String
}

struct AccountUpdateRequest: Codable {
    let name: String
    let balance: String
    let currency: String
}
