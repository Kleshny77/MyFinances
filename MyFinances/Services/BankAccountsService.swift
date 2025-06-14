//
//  BankAccountsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

struct BankAccountsService {
    func fetchAccount() async throws -> BankAccount {
        let raw: [[String: Any]] = [
            [
                "id": 1,
                "userId": 1,
                "name": "Основной счёт",
                "balance": "1000.00",
                "currency": "RUB",
                "createdAt": "2025-06-13T23:21:48.542Z",
                "updatedAt": "2025-06-13T23:21:48.542Z"
            ],
            [
                "id": 2,
                "userId": 1,
                "name": "Дополнительный счёт",
                "balance": "503.00",
                "currency": "RUB",
                "createdAt": "2026-08-10T01:52:44.133Z",
                "updatedAt": "2026-08-10T01:52:44.133Z"
            ]
        ]
        
        guard let first = raw.first else {
            throw ServersError.emptyAccountsList
        }
        
        return try BankAccount.parse(jsonObject: first)
    }
    
    func updateAccount(account: BankAccount, name: String? = nil, balance: Decimal? = nil, currency: String? = nil) async throws -> BankAccount {
        let updated = BankAccount(id: account.id, userId: account.userId, name: name ?? account.name, balance: balance ?? account.balance, currency: currency ?? account.currency, createdAt: account.createdAt, updatedAt: Date.now)
        
        return updated
    }
}
