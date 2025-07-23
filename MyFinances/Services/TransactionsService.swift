//
//  TransactionsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с транзакциями
@MainActor
struct TransactionsService {
    private let networkClient: NetworkClient
    private let localStorage: TransactionsStorage
    private let backupStorage: BackupStorage
    
    init(networkClient: NetworkClient, localStorage: TransactionsStorage, backupStorage: BackupStorage) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }
    
    // MARK: - Фабричный метод для создания сервиса с дефолтным NetworkClient
    static func create() -> TransactionsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        
        return TransactionsService(networkClient: networkClient, localStorage: MockTransactionsStorage(), backupStorage: MockBackupStorage())
    }
    
    // MARK: - Асинхронная версия с локальным хранением
    static func createWithLocalStorage() async -> TransactionsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        
        do {
            let localStorage = try SwiftDataTransactionsStorage()
            let backupStorage = try SwiftDataBackupStorage()
            return TransactionsService(networkClient: networkClient, localStorage: localStorage, backupStorage: backupStorage)
        } catch {
            return TransactionsService(networkClient: networkClient, localStorage: MockTransactionsStorage(), backupStorage: MockBackupStorage())
        }
    }
    
    func fetchTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [TransactionResponse] {
        do {
            try await syncBackupOperations(accountId: accountId)
        } catch {
        }
        
        do {
            let networkTransactions = try await fetchFromNetwork(accountId: accountId, startDate: startDate, endDate: endDate)
            
            for transactionResponse in networkTransactions {
                let transaction = Transaction.fromAPI(transactionResponse)
                do {
                    try await localStorage.createTransaction(transaction)
                } catch {
                    continue
                }
            }
            
            return networkTransactions
            
        } catch {
            do {
                return try await getLocalTransactions(accountId: accountId, startDate: startDate, endDate: endDate)
            } catch {
                return []
            }
        }
    }
    
    func createTransaction(request: TransactionRequest) async throws {
        do {
            try await createTransactionOnNetwork(request: request)
            
            let transaction = try await createLocalTransaction(from: request)
            do {
                try await localStorage.createTransaction(transaction)
            } catch {
            }
            
            do {
                try await updateAccountBalance(accountId: request.accountId, amount: transaction.amount, isIncome: transaction.category.isIncome)
            } catch {
            }
            
            do {
                try await backupStorage.removeBackupOperation(id: transaction.id)
            } catch {
            }
            
        } catch {
            let backupOperation = BackupOperation(
                id: Int.random(in: 1000000...9999999),
                action: .create,
                accountId: request.accountId,
                categoryId: request.categoryId,
                amount: Decimal(string: request.amount) ?? 0,
                transactionDate: DateFormatterFactory.iso8601Full.date(from: request.transactionDate) ?? Date(),
                comment: request.comment
            )
            do {
                try await backupStorage.addBackupOperation(backupOperation)
            } catch {
            }
            throw error
        }
    }
    
    func updateTransaction(id: Int, request: TransactionRequest) async throws {
        let oldTransaction = try await localStorage.getTransaction(id: id)
        
        do {
            try await updateTransactionOnNetwork(id: id, request: request)
            
            let newTransaction = try await updateLocalTransaction(id: id, from: request)
            do {
                try await localStorage.updateTransaction(newTransaction)
            } catch {
            }
            
            if let oldTransaction = oldTransaction {
                let oldAmount = oldTransaction.amount
                let newAmount = newTransaction.amount
                let oldIsIncome = oldTransaction.category.isIncome
                let newIsIncome = newTransaction.category.isIncome
                
                let oldBalanceChange = oldIsIncome ? oldAmount : -oldAmount
                try await updateAccountBalance(accountId: request.accountId, amount: oldBalanceChange, isIncome: !oldIsIncome)
                
                let newBalanceChange = newIsIncome ? newAmount : -newAmount
                try await updateAccountBalance(accountId: request.accountId, amount: newBalanceChange, isIncome: newIsIncome)
            } else {
                let balanceChange = newTransaction.category.isIncome ? newTransaction.amount : -newTransaction.amount
                try await updateAccountBalance(accountId: request.accountId, amount: balanceChange, isIncome: newTransaction.category.isIncome)
            }
            
            do {
                try await backupStorage.removeBackupOperation(id: id)
            } catch {
            }
            
        } catch {
            let backupOperation = BackupOperation(
                id: id,
                action: .update,
                accountId: request.accountId,
                categoryId: request.categoryId,
                amount: Decimal(string: request.amount) ?? 0,
                transactionDate: DateFormatterFactory.iso8601Full.date(from: request.transactionDate) ?? Date(),
                comment: request.comment
            )
            do {
                try await backupStorage.addBackupOperation(backupOperation)
            } catch {
            }
            throw error
        }
    }
    
    func deleteTransaction(id: Int) async throws {
        let transaction = try await localStorage.getTransaction(id: id)
        
        do {
            try await deleteTransactionOnNetwork(id: id)
            
            do {
                try await localStorage.deleteTransaction(id: id)
            } catch {
            }
            
            if let transaction = transaction {
                let balanceChange = transaction.category.isIncome ? -transaction.amount : transaction.amount
                try await updateAccountBalance(accountId: transaction.account.id, amount: balanceChange, isIncome: !transaction.category.isIncome)
            }
            
            do {
                try await backupStorage.removeBackupOperation(id: id)
            } catch {
            }
            
        } catch {
            let accountId: Int
            do {
                if let existingTransaction = try await localStorage.getTransaction(id: id) {
                    accountId = existingTransaction.account.id
                } else {
                    accountId = 0
                }
            } catch {
                accountId = 0
            }
            
            let backupOperation = BackupOperation(
                id: id,
                action: .delete,
                accountId: accountId
            )
            do {
                try await backupStorage.addBackupOperation(backupOperation)
            } catch {
            }
            throw error
        }
    }
    
    // MARK: - Приватные методы
    private func syncBackupOperations(accountId: Int) async throws {
        let backupOperations = try await backupStorage.getBackupOperations(accountId: accountId)
        
        for operation in backupOperations {
            do {
                switch operation.backupAction {
                case .create:
                    let request = createTransactionRequest(from: operation)
                    try await createTransactionOnNetwork(request: request)
                case .update:
                    let request = createTransactionRequest(from: operation)
                    try await updateTransactionOnNetwork(id: operation.id, request: request)
                case .delete:
                    try await deleteTransactionOnNetwork(id: operation.id)
                }
                
                do {
                    try await backupStorage.removeBackupOperation(id: operation.id)
                } catch {
                }
                
            } catch {
                continue
            }
        }
    }
    
    private func fetchFromNetwork(accountId: Int, startDate: String, endDate: String) async throws -> [TransactionResponse] {
        var urlComponents = URLComponents(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactionsByAccount + "/\(accountId)/period")!
        urlComponents.queryItems = [
            URLQueryItem(name: NetworkConstants.QueryParams.startDate, value: startDate),
            URLQueryItem(name: NetworkConstants.QueryParams.endDate, value: endDate)
        ]
        let url = urlComponents.url!
        return try await networkClient.request(url: url)
    }
    
    private func getLocalTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [TransactionResponse] {
        let localTransactions: [Transaction]
        let backupOperations: [BackupOperation]
        
        do {
            localTransactions = try await localStorage.getTransactions(accountId: accountId, startDate: startDate, endDate: endDate)
        } catch {
            localTransactions = []
        }
        
        do {
            backupOperations = try await backupStorage.getBackupOperations(accountId: accountId)
        } catch {
            backupOperations = []
        }
        
        var mergedTransactions = localTransactions
        
        for operation in backupOperations {
            switch operation.backupAction {
            case .create, .update:
                if let transaction = createTransactionFromBackup(operation) {
                    mergedTransactions.append(transaction)
                }
            case .delete:
                mergedTransactions.removeAll { $0.id == operation.id }
            }
        }
        
        return mergedTransactions.map { transaction in
            TransactionResponse(
                id: transaction.id,
                account: AccountBrief(
                    id: transaction.account.id,
                    name: transaction.account.name,
                    balance: String(describing: transaction.account.balance),
                    currency: transaction.account.currency
                ),
                category: CategoryAPI(
                    id: transaction.category.id,
                    name: transaction.category.name,
                    emoji: String(transaction.category.emoji),
                    isIncome: transaction.category.isIncome
                ),
                amount: String(describing: transaction.amount),
                transactionDate: DateFormatterFactory.iso8601Full.string(from: transaction.transactionDate),
                comment: transaction.comment ?? "",
                createdAt: DateFormatterFactory.iso8601Full.string(from: transaction.createdAt),
                updatedAt: DateFormatterFactory.iso8601Full.string(from: transaction.updatedAt)
            )
        }
    }
    
    private func createTransactionOnNetwork(request: TransactionRequest) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactions)!
        _ = try await networkClient.request(url: url, method: "POST", body: request) as EmptyResponse
    }
    
    private func updateTransactionOnNetwork(id: Int, request: TransactionRequest) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactions + "/\(id)")!
        _ = try await networkClient.request(url: url, method: "PUT", body: request) as EmptyResponse
    }
    
    private func deleteTransactionOnNetwork(id: Int) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactions + "/\(id)")!
        _ = try await networkClient.request(url: url, method: "DELETE") as EmptyResponse
    }
    
    private func createLocalTransaction(from request: TransactionRequest) async throws -> Transaction {
        let id = Int.random(in: 1000000...9999999)
        let account: BankAccount
        do {
            let accounts = try await getAccountStorage().getAccount()
            if let localAccount = accounts {
                account = localAccount
            } else {
                account = BankAccount(id: request.accountId, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date())
            }
        } catch {
            account = BankAccount(id: request.accountId, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date())
        }
        
        let category: Category
        do {
            let categories = try await getCategoriesStorage().getAllCategories()
            if let localCategory = categories.first(where: { $0.id == request.categoryId }) {
                category = localCategory
            } else {
                category = Category(id: request.categoryId, name: "", emoji: "📁", isIncome: false)
            }
        } catch {
            category = Category(id: request.categoryId, name: "", emoji: "📁", isIncome: false)
        }
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: Decimal(string: request.amount) ?? 0,
            transactionDate: DateFormatterFactory.iso8601Full.date(from: request.transactionDate) ?? Date(),
            comment: request.comment,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    private func updateLocalTransaction(id: Int, from request: TransactionRequest) async throws -> Transaction {
        let account: BankAccount
        do {
            let accounts = try await getAccountStorage().getAccount()
            if let localAccount = accounts {
                account = localAccount
            } else {
                account = BankAccount(id: request.accountId, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date())
            }
        } catch {
            account = BankAccount(id: request.accountId, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date())
        }
        
        let category: Category
        do {
            let categories = try await getCategoriesStorage().getAllCategories()
            if let localCategory = categories.first(where: { $0.id == request.categoryId }) {
                category = localCategory
            } else {
                category = Category(id: request.categoryId, name: "", emoji: "📁", isIncome: false)
            }
        } catch {
            category = Category(id: request.categoryId, name: "", emoji: "📁", isIncome: false)
        }
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: Decimal(string: request.amount) ?? 0,
            transactionDate: DateFormatterFactory.iso8601Full.date(from: request.transactionDate) ?? Date(),
            comment: request.comment,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
    
    private func createTransactionRequest(from operation: BackupOperation) -> TransactionRequest {
        return TransactionRequest(
            accountId: operation.accountId,
            categoryId: operation.categoryId ?? 0,
            amount: String(describing: operation.amount ?? 0),
            transactionDate: DateFormatterFactory.iso8601Full.string(from: operation.transactionDate ?? Date()),
            comment: operation.comment ?? ""
        )
    }
    
    private func createTransactionFromBackup(_ operation: BackupOperation) -> Transaction? {
        guard let categoryId = operation.categoryId,
              let amount = operation.amount,
              let transactionDate = operation.transactionDate else {
            return nil
        }
        
        let account = BankAccount(id: operation.accountId, userId: 0, name: "", balance: 0, currency: "", createdAt: Date(), updatedAt: Date())
        let category = Category(id: categoryId, name: "", emoji: "📁", isIncome: false)
        
        return Transaction(
            id: operation.id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: operation.comment,
            createdAt: operation.createdAt,
            updatedAt: operation.createdAt
        )
    }
    
    private func getAccountStorage() -> AccountStorage {
        return MockAccountStorage()
    }
    
    private func getCategoriesStorage() -> CategoriesStorage {
        return MockCategoriesStorage()
    }
    
    private func updateAccountBalance(accountId: Int, amount: Decimal, isIncome: Bool) async throws {
        let accountService = await BankAccountsService.createWithLocalStorage()
        try await accountService.updateAccountBalance(accountId: accountId, amount: amount, isIncome: isIncome)
    }
}
