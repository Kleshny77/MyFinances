//
//  BackupOperation.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

enum BackupAction: String, Codable, Sendable {
    case create = "create"
    case update = "update"
    case delete = "delete"
}

@Model
final class BackupOperation {
    var id: Int
    var action: String // BackupAction.rawValue
    var accountId: Int
    var categoryId: Int?
    var amount: Decimal?
    var transactionDate: Date?
    var comment: String?
    var createdAt: Date
    
    init(id: Int, action: BackupAction, accountId: Int, categoryId: Int? = nil, amount: Decimal? = nil, transactionDate: Date? = nil, comment: String? = nil) {
        self.id = id
        self.action = action.rawValue
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = Date()
    }
    
    var backupAction: BackupAction {
        get { BackupAction(rawValue: action) ?? .create }
        set { action = newValue.rawValue }
    }
    
    convenience init(create transaction: Transaction) {
        self.init(
            id: transaction.id,
            action: .create,
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment
        )
    }
    
    convenience init(update transaction: Transaction) {
        self.init(
            id: transaction.id,
            action: .update,
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment
        )
    }
    
    convenience init(delete transactionId: Int, accountId: Int) {
        self.init(
            id: transactionId,
            action: .delete,
            accountId: accountId
        )
    }
} 