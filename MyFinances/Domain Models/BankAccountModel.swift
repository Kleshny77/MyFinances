//
//  BankAccountModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}
