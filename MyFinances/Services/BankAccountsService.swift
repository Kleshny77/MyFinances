//
//  BankAccountsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с аккаунтом
@MainActor
final class BankAccountsService {
    private let networkClient: NetworkClient
    private let localStorage: AccountStorage
    private let backupStorage: BackupStorage
    
    init(networkClient: NetworkClient, localStorage: AccountStorage, backupStorage: BackupStorage) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
    }
    
    static func create() -> BankAccountsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        return BankAccountsService(networkClient: networkClient, localStorage: MockAccountStorage(), backupStorage: MockBackupStorage())
    }
    
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
    
    func fetchAccount() async throws -> BankAccount? {
        do {
            let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts)! 
            let response: [AccountResponse] = try await networkClient.request(url: url)
            if let first = response.first {
                let account = BankAccount.fromAPI(first)
                do { try await localStorage.saveAccount(account) } catch { }
                return account
            } else {
                // Если с бэка ничего не пришло — пробуем вернуть локальный аккаунт
                let local = try await localStorage.getAccount()
                if let local = local {
                    return local
                } else {
                    // Если и локально ничего нет — создаём дефолтный аккаунт
                    let defaultAccount = BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 0, currency: "RUB", createdAt: Date(), updatedAt: Date())
                    do { try await localStorage.saveAccount(defaultAccount) } catch { }
                    return defaultAccount
                }
            }
        } catch {
            do {
                let local = try await localStorage.getAccount()
                if let local = local {
                    return local
                } else {
                    return BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 0, currency: "RUB", createdAt: Date(), updatedAt: Date())
                }
            } catch {
                return BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 0, currency: "RUB", createdAt: Date(), updatedAt: Date())
            }
        }
    }
    
    func createAccount(request: AccountCreateRequest) async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts)!
        let response: AccountResponse = try await networkClient.request(url: url, method: NetworkConstants.Methods.post, body: request)
        return BankAccount.fromAPI(response)
    }
    
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> BankAccount? {
        do {
            let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts + "/\(id)")!
            _ = try await networkClient.request(url: url, method: NetworkConstants.Methods.put, body: request) as EmptyResponse
            let updatedAccount = BankAccount(id: id, userId: 0, name: request.name, balance: Decimal(string: request.balance) ?? 0, currency: request.currency, createdAt: Date(), updatedAt: Date())
            do { try await localStorage.updateAccount(updatedAccount) } catch {}
            do { try await backupStorage.removeBackupOperation(id: id) } catch {}
            return updatedAccount
        } catch {
            let backup = BackupOperation(id: id, action: .update, accountId: id)
            do { try await backupStorage.addBackupOperation(backup) } catch {}
            throw error
        }
    }
    
    func updateAccountBalance(accountId: Int, amount: Decimal, isIncome: Bool) async throws {
        guard var account = try await localStorage.getAccount() else { return }
        let newBalance = isIncome ? (account.balance + amount) : (account.balance - amount)
        account = BankAccount(id: account.id, userId: account.userId, name: account.name, balance: newBalance, currency: account.currency, createdAt: account.createdAt, updatedAt: Date())
        do { try await localStorage.updateAccount(account) } catch {}
    }
    
    func ensureAccountHasName() async throws -> BankAccount {
        var account = try await fetchAccount()
        if account?.name.isEmpty ?? true {
            let updateRequest = AccountUpdateRequest(
                name: "Основной счёт",
                balance: String(format: "%.2f", NSDecimalNumber(decimal: account?.balance ?? 0).doubleValue),
                currency: account?.currency ?? ""
            )
            account = try await updateAccount(id: account?.id ?? 0, request: updateRequest)
        }
        return account ?? BankAccount(id: 0, userId: 0, name: "Основной счёт", balance: 0, currency: "RUB", createdAt: Date(), updatedAt: Date())
    }
}
