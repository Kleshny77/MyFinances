//
//  BankAccountsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с аккаунтом
struct BankAccountsService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    static func create() -> BankAccountsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        return BankAccountsService(networkClient: networkClient)
    }
    
    func fetchAccount() async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts)!
        let accounts: [AccountResponse] = try await networkClient.request(url: url)
        guard let first = accounts.first else {
            throw NetworkError.httpError(code: 404, data: Data())
        }
        return BankAccount.fromAPI(first)
    }
    
    func createAccount(request: AccountCreateRequest) async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts)!
        let response: AccountResponse = try await networkClient.request(url: url, method: NetworkConstants.Methods.post, body: request)
        return BankAccount.fromAPI(response)
    }
    
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> BankAccount {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.accounts + "/\(id)")!
        let response: AccountResponse = try await networkClient.request(url: url, method: NetworkConstants.Methods.put, body: request)
        return BankAccount.fromAPI(response)
    }
    
    // Получить аккаунт и при необходимости задать имя
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
}
