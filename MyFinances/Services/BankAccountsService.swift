//
//  BankAccountsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с аккаунтом
@MainActor
struct BankAccountsService {
    private let networkClient: NetworkClient
    private let localStorage: AccountStorage
    private let backupStorage: BackupStorage
    
    init(networkClient: NetworkClient, localStorage: AccountStorage, backupStorage: BackupStorage) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }
    
    // MARK: - Фабричный метод для создания сервиса с дефолтным NetworkClient
    static func create() -> BankAccountsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        return BankAccountsService(networkClient: networkClient, localStorage: MockAccountStorage(), backupStorage: MockBackupStorage())
    }
    
    // MARK: - Асинхронная версия с локальным хранением
    static func createWithLocalStorage() async -> BankAccountsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        
        do {
            let localStorage = try SwiftDataAccountStorage()
            let backupStorage = try SwiftDataBackupStorage()
            return BankAccountsService(networkClient: networkClient, localStorage: localStorage, backupStorage: backupStorage)
        } catch {
            return BankAccountsService(networkClient: networkClient, localStorage: MockAccountStorage(), backupStorage: MockBackupStorage())
        }
    }
    
    func fetchAccount() async throws -> BankAccount {
        do {
            try await syncBackupOperations()
        } catch {
        }
        
        do {
            let networkAccount = try await fetchFromNetwork()
            
            do {
                try await localStorage.saveAccount(networkAccount)
            } catch {
            }
            
            return networkAccount
            
        } catch {
            do {
                if let localAccount = try await localStorage.getAccount() {
                    return localAccount
                } else {
                    throw error
                }
            } catch {
                throw error
            }
        }
    }
    
    func createAccount(request: AccountCreateRequest) async throws -> BankAccount {
        do {
            let networkAccount = try await createAccountOnNetwork(request: request)
            
            do {
                try await localStorage.saveAccount(networkAccount)
            } catch {
            }
            
            do {
                try await backupStorage.removeBackupOperation(id: networkAccount.id)
            } catch {
            }
            
            return networkAccount
            
        } catch {
            let backupOperation = BackupOperation(
                id: Int.random(in: 1000000...9999999),
                action: .create,
                accountId: 0,
                categoryId: nil,
                amount: 0,
                transactionDate: Date(),
                comment: "Account creation"
            )
            do {
                try await backupStorage.addBackupOperation(backupOperation)
            } catch {
            }
            throw error
        }
    }
    
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> BankAccount {
        do {
            let networkAccount = try await updateAccountOnNetwork(id: id, request: request)
            
            do {
                try await localStorage.updateAccount(networkAccount)
            } catch {
            }
            
            do {
                try await backupStorage.removeBackupOperation(id: id)
            } catch {
            }
            
            return networkAccount
            
        } catch {
            let backupOperation = BackupOperation(
                id: id,
                action: .update,
                accountId: id,
                categoryId: nil,
                amount: 0,
                transactionDate: Date(),
                comment: "Account update"
            )
            do {
                try await backupStorage.addBackupOperation(backupOperation)
            } catch {
            }
            throw error
        }
    }
    
    func ensureAccountHasName() async throws -> BankAccount {
        var account = try await fetchAccount()
        if account.name.isEmpty {
            let updateRequest = AccountUpdateRequest(
                name: "Основной счёт",
                balance: String(format: "%.2f", NSDecimalNumber(decimal: account.balance).doubleValue),
                currency: account.currency
            )
            account = try await updateAccount(id: account.id, request: updateRequest)
        }
        return account
    }
    
    // MARK: - Метод для обновления баланса при транзакциях
    func updateAccountBalance(accountId: Int, amount: Decimal, isIncome: Bool) async throws {
        let currentAccount = try await fetchAccount()
        
        let newBalance: Decimal
        if isIncome {
            newBalance = currentAccount.balance + amount
        } else {
            newBalance = currentAccount.balance - amount
        }
        
        let updatedAccount = BankAccount(
            id: currentAccount.id,
            userId: currentAccount.userId,
            name: currentAccount.name,
            balance: newBalance,
            currency: currentAccount.currency,
            createdAt: currentAccount.createdAt,
            updatedAt: Date()
        )
        
        do {
            try await localStorage.updateAccount(updatedAccount)
        } catch {
        }
    }
    
    // MARK: - Приватные методы
    private func syncBackupOperations() async throws {
        let backupOperations = try await backupStorage.getAllBackupOperations()
        
        for operation in backupOperations {
            do {
                switch operation.backupAction {
                case .create:
                    continue
                case .update:
                    continue
                case .delete:
                    try await deleteAccountOnNetwork(id: operation.id)
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
    
    private func fetchFromNetwork() async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts)!
        let accounts: [AccountResponse] = try await networkClient.request(url: url)
        guard let first = accounts.first else {
            throw NetworkError.httpError(code: 404, data: Data())
        }
        return BankAccount.fromAPI(first)
    }
    
    private func createAccountOnNetwork(request: AccountCreateRequest) async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts)!
        let data = try JSONEncoder().encode(request)
        let response: AccountResponse = try await networkClient.request(url: url, method: "POST", body: data)
        return BankAccount.fromAPI(response)
    }
    
    private func updateAccountOnNetwork(id: Int, request: AccountUpdateRequest) async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts + "/\(id)")!
        let data = try JSONEncoder().encode(request)
        let response: AccountResponse = try await networkClient.request(url: url, method: "PUT", body: data)
        return BankAccount.fromAPI(response)
    }
    
    private func deleteAccountOnNetwork(id: Int) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts + "/\(id)")!
        _ = try await networkClient.request(url: url, method: "DELETE") as EmptyResponse
    }
}
