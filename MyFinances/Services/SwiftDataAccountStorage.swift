//
//  SwiftDataAccountStorage.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataAccountStorage: AccountStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([
            LocalTransaction.self,
            BackupOperation.self,
            LocalAccount.self,
            LocalCategory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(modelContainer)
    }
    
    func getAccount() async throws -> BankAccount? {
        let descriptor = FetchDescriptor<LocalAccount>()
        let localAccounts = try modelContext.fetch(descriptor)
        return localAccounts.first?.toBankAccount()
    }
    
    func saveAccount(_ account: BankAccount) async throws {
        let localAccount = LocalAccount(from: account)
        modelContext.insert(localAccount)
        try modelContext.save()
    }
    
    func updateAccount(_ account: BankAccount) async throws {
        let descriptor = FetchDescriptor<LocalAccount>()
        let localAccounts = try modelContext.fetch(descriptor)
        
        if let existingAccount = localAccounts.first {
            existingAccount.name = account.name
            existingAccount.balance = account.balance
            existingAccount.currency = account.currency
            existingAccount.updatedAt = Date()
            try modelContext.save()
        } else {
            // Если аккаунт не найден, создаем новый
            try await saveAccount(account)
        }
    }
    
    func clearAll() async throws {
        let descriptor = FetchDescriptor<LocalAccount>()
        let localAccounts = try modelContext.fetch(descriptor)
        
        for localAccount in localAccounts {
            modelContext.delete(localAccount)
        }
        try modelContext.save()
    }
} 