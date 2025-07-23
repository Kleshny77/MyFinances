import Foundation

@MainActor
final class MockTransactionsStorage: TransactionsStorage {
    func getAllTransactions() async throws -> [Transaction] { return [] }
    func getTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [Transaction] { return [] }
    func getTransaction(id: Int) async throws -> Transaction? { return nil }
    func createTransaction(_ transaction: Transaction) async throws {}
    func updateTransaction(_ transaction: Transaction) async throws {}
    func deleteTransaction(id: Int) async throws {}
    func clearAll() async throws {}
}

@MainActor
final class MockBackupStorage: BackupStorage {
    func getAllBackupOperations() async throws -> [BackupOperation] { return [] }
    func getBackupOperations(accountId: Int) async throws -> [BackupOperation] { return [] }
    func addBackupOperation(_ operation: BackupOperation) async throws {}
    func removeBackupOperation(id: Int) async throws {}
    func clearAll() async throws {}
}

@MainActor
final class MockAccountStorage: AccountStorage {
    func getAccount() async throws -> BankAccount? { return nil }
    func saveAccount(_ account: BankAccount) async throws {}
    func updateAccount(_ account: BankAccount) async throws {}
    func clearAll() async throws {}
}

@MainActor
final class MockCategoriesStorage: CategoriesStorage {
    func getAllCategories() async throws -> [Category] { return [] }
    func saveCategories(_ categories: [Category]) async throws {}
    func clearAll() async throws {}
} 