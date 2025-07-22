//
//  BankAccountsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с аккаунтом
struct BankAccountsService {
    func fetchAccount() async throws -> BankAccount {
        return try await TransactionsService().fetchTransactions(from: .distantPast, to: .distantFuture)[0].account
    }
    
    func updateAccount(account: BankAccount, name: String? = nil, balance: Decimal? = nil, currency: String? = nil) async throws -> BankAccount {
        let updated = BankAccount(id: account.id, userId: account.userId, name: name ?? account.name, balance: balance ?? account.balance, currency: currency ?? account.currency, createdAt: account.createdAt, updatedAt: Date.now)
        
        return updated
    }
}
