//
//  TransactionsStorage.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation

// MARK: - Протокол для хранения транзакций
@MainActor
protocol TransactionsStorage {
    func getAllTransactions() async throws -> [Transaction]
    func getTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [Transaction]
    func getTransaction(id: Int) async throws -> Transaction?
    func createTransaction(_ transaction: Transaction) async throws
    func updateTransaction(_ transaction: Transaction) async throws
    func deleteTransaction(id: Int) async throws
    func clearAll() async throws
}

// MARK: - Протокол для backup операций
@MainActor
protocol BackupStorage {
    func getAllBackupOperations() async throws -> [BackupOperation]
    func getBackupOperations(accountId: Int) async throws -> [BackupOperation]
    func addBackupOperation(_ operation: BackupOperation) async throws
    func removeBackupOperation(id: Int) async throws
    func clearAll() async throws
}

// MARK: - Протокол для хранения аккаунтов
@MainActor
protocol AccountStorage {
    func getAccount() async throws -> BankAccount?
    func saveAccount(_ account: BankAccount) async throws
    func updateAccount(_ account: BankAccount) async throws
    func clearAll() async throws
}

// MARK: - Протокол для хранения категорий
@MainActor
protocol CategoriesStorage {
    func getAllCategories() async throws -> [Category]
    func saveCategories(_ categories: [Category]) async throws
    func clearAll() async throws
} 