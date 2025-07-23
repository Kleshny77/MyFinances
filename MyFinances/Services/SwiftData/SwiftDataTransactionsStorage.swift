//
//  SwiftDataTransactionsStorage.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataTransactionsStorage: TransactionsStorage {
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
    
    func getAllTransactions() async throws -> [Transaction] {
        let descriptor = FetchDescriptor<LocalTransaction>()
        let localTransactions = try modelContext.fetch(descriptor)
        let accounts = try await getAccounts()
        let categories = try await getCategories()
        return localTransactions.compactMap { localTransaction in
            guard let account = accounts.first(where: { $0.id == localTransaction.accountId }),
                  let category = categories.first(where: { $0.id == localTransaction.categoryId }) else {
                return nil
            }
            return localTransaction.toTransaction(account: account, category: category)
        }
    }
    
    func getTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [Transaction] {
        let startDateObj = DateFormatterFactory.yyyyMMdd.date(from: startDate) ?? Date()
        let endDateObj = DateFormatterFactory.yyyyMMdd.date(from: endDate) ?? Date()
        let descriptor = FetchDescriptor<LocalTransaction>(
            predicate: #Predicate<LocalTransaction> { transaction in
                transaction.accountId == accountId &&
                transaction.transactionDate >= startDateObj &&
                transaction.transactionDate <= endDateObj
            }
        )
        let localTransactions = try modelContext.fetch(descriptor)
        let accounts = try await getAccounts()
        let categories = try await getCategories()
        return localTransactions.compactMap { localTransaction in
            guard let account = accounts.first(where: { $0.id == localTransaction.accountId }),
                  let category = categories.first(where: { $0.id == localTransaction.categoryId }) else {
                return nil
            }
            return localTransaction.toTransaction(account: account, category: category)
        }
    }
    
    func getTransaction(id: Int) async throws -> Transaction? {
        let descriptor = FetchDescriptor<LocalTransaction>(
            predicate: #Predicate<LocalTransaction> { transaction in
                transaction.id == id
            }
        )
        let localTransactions = try modelContext.fetch(descriptor)
        guard let localTransaction = localTransactions.first else { return nil }
        let accounts = try await getAccounts()
        let categories = try await getCategories()
        guard let account = accounts.first(where: { $0.id == localTransaction.accountId }),
              let category = categories.first(where: { $0.id == localTransaction.categoryId }) else {
            return nil
        }
        return localTransaction.toTransaction(account: account, category: category)
    }
    
    func createTransaction(_ transaction: Transaction) async throws {
        let localTransaction = LocalTransaction(from: transaction)
        modelContext.insert(localTransaction)
        try modelContext.save()
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        let transactionId = transaction.id
        let descriptor = FetchDescriptor<LocalTransaction>(
            predicate: #Predicate<LocalTransaction> { localTransaction in
                localTransaction.id == transactionId
            }
        )
        let localTransactions = try modelContext.fetch(descriptor)
        if let existingTransaction = localTransactions.first {
            existingTransaction.accountId = transaction.account.id
            existingTransaction.categoryId = transaction.category.id
            existingTransaction.amount = transaction.amount
            existingTransaction.transactionDate = transaction.transactionDate
            existingTransaction.comment = transaction.comment
            existingTransaction.updatedAt = Date()
            try modelContext.save()
        } else {
            try await createTransaction(transaction)
        }
    }
    
    func deleteTransaction(id: Int) async throws {
        let descriptor = FetchDescriptor<LocalTransaction>(
            predicate: #Predicate<LocalTransaction> { transaction in
                transaction.id == id
            }
        )
        let localTransactions = try modelContext.fetch(descriptor)
        for localTransaction in localTransactions {
            modelContext.delete(localTransaction)
        }
        try modelContext.save()
    }
    
    func clearAll() async throws {
        let descriptor = FetchDescriptor<LocalTransaction>()
        let localTransactions = try modelContext.fetch(descriptor)
        for localTransaction in localTransactions {
            modelContext.delete(localTransaction)
        }
        try modelContext.save()
    }
    // MARK: - Вспомогательные методы
    private func getAccounts() async throws -> [BankAccount] {
        let descriptor = FetchDescriptor<LocalAccount>()
        let localAccounts = try modelContext.fetch(descriptor)
        return localAccounts.map { $0.toBankAccount() }
    }
    private func getCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<LocalCategory>()
        let localCategories = try modelContext.fetch(descriptor)
        return localCategories.map { $0.toCategory() }
    }
} 