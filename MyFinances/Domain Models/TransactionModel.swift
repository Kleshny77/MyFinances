//
//  TransactionModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

// MARK: - Модель транзакции
struct Transaction: Equatable, Identifiable {
    let id: Int
    var account: BankAccount
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
}

struct TransactionRequest: Codable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String

    enum CodingKeys: String, CodingKey {
        case accountId, categoryId, amount, transactionDate, comment
    }
}

// MARK: - TransactionResponse для API
struct TransactionResponse: Codable {
    let id: Int

    let account: AccountBrief
    let category: CategoryAPI

    let amount: String
    let transactionDate: String
    let comment: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case account, category
        case amount, transactionDate, comment, createdAt, updatedAt
    }
}

// MARK: - AccountBrief для TransactionResponse
struct AccountBrief: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}

extension Transaction {
    static func fromAPI(_ api: TransactionResponse) -> Transaction {
        let account = BankAccount(
            id: api.account.id,
            userId: 0,
            name: api.account.name,
            balance: Decimal(string: api.account.balance) ?? 0,
            currency: api.account.currency,
            createdAt: Date(),
            updatedAt: Date()
        )
        let category = api.category.toDomain()
        let trxDate = DateFormatterFactory.iso8601Full.date(from: api.transactionDate) ?? Date()
        let created = DateFormatterFactory.iso8601Full.date(from: api.createdAt) ?? trxDate
        let updated = DateFormatterFactory.iso8601Full.date(from: api.updatedAt) ?? created
        let decimal = Decimal(string: api.amount) ?? 0
        let cleanComment: String? = {
            let c = api.comment.trimmingCharacters(in: .whitespacesAndNewlines)
            return c.isEmpty ? nil : c
        }()
        return Transaction(
            id: api.id,
            account: account,
            category: category,
            amount: decimal,
            transactionDate: trxDate,
            comment: cleanComment,
            createdAt: created,
            updatedAt: updated
        )
    }
}
