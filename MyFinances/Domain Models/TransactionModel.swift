//
//  TransactionModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

// MARK: - Модель транзакции
struct Transaction: Equatable {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
}

