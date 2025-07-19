//
//  LocalTransaction.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class LocalTransaction {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String?) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    convenience init(from transaction: Transaction) {
        self.init(
            id: transaction.id,
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment
        )
    }
    
    func toTransaction(account: BankAccount, category: Category) -> Transaction {
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
} 