//
//  BankAccountsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

struct BankAccountsService {
    func fetchAccount() async throws -> BankAccount {
        let account = [
            BankAccount(id: 1, userId: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB", createdAt: parseISODate("2025-06-10T01:52:44.133Z"), updatedAt: parseISODate("2025-06-10T01:52:44.133Z")),
            BankAccount(id: 2, userId: 1, name: "Дополнительный счёт", balance: 503.00, currency: "RUB", createdAt: parseISODate("2026-08-10T01:52:44.133Z"), updatedAt: parseISODate("2026-08-10T01:52:44.133Z"))
        ].first!
        
        func parseISODate(_ str: String) -> Date {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            return formatter.date(from: str)!
        }
        
        return account
    }
    
    func updateAccount(account: BankAccount, name: String?, balance: Decimal?, currency: String?) async throws -> BankAccount {
        let updated = BankAccount(id: account.id, userId: account.userId, name: name ?? account.name, balance: balance ?? account.balance, currency: currency ?? account.currency, createdAt: account.createdAt, updatedAt: Date.now)
        
        return updated
    }
}
