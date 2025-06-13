//
//  TransactionModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

// MARK: - Модель транзакции
struct Transaction: Equatable {
    let id: Int
    var account: BankAccount
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
}

