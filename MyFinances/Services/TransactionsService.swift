//
//  TransactionsService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с транзакциями
struct TransactionsService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Фабричный метод для создания сервиса с дефолтным NetworkClient
    static func create() -> TransactionsService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        return TransactionsService(networkClient: networkClient)
    }
    
    func fetchTransactions(accountId: Int, startDate: String, endDate: String) async throws -> [TransactionResponse] {
        var urlComponents = URLComponents(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactionsByAccount + "/\(accountId)/period")!
        urlComponents.queryItems = [
            URLQueryItem(name: NetworkConstants.QueryParams.startDate, value: startDate),
            URLQueryItem(name: NetworkConstants.QueryParams.endDate, value: endDate)
        ]
        let url = urlComponents.url!
        return try await networkClient.request(url: url)
    }
    
    func createTransaction(request: TransactionRequest) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactions)!
        _ = try await networkClient.request(url: url, method: NetworkConstants.Methods.post, body: request) as EmptyResponse
    }
    
    func updateTransaction(id: Int, request: TransactionRequest) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactions + "/\(id)")!
        _ = try await networkClient.request(url: url, method: NetworkConstants.Methods.put, body: request) as EmptyResponse
    }
    
    func deleteTransaction(id: Int) async throws {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.transactions + "/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = NetworkConstants.Methods.delete
        request.setValue(NetworkConstants.Headers.bearerPrefix + NetworkConstants.authToken, forHTTPHeaderField: NetworkConstants.Headers.authorization)
        request.setValue(NetworkConstants.Headers.jsonContentType, forHTTPHeaderField: NetworkConstants.Headers.contentType)
        
        let (data, response) = try await networkClient.session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(code: httpResponse.statusCode, data: data)
        }
        
        // Успешное удаление, не пытаемся декодировать ответ
    }
}

// MARK: - Заглушка для пустого ответа
struct EmptyResponse: Decodable {}
