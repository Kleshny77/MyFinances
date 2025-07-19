//
//  LocalAccount.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class LocalAccount {
    var id: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    convenience init(from account: BankAccount) {
        self.init(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
    }
    
    func toBankAccount() -> BankAccount {
        return BankAccount(
            id: id,
            userId: 0, // По умолчанию
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
} 