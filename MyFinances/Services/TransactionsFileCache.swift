//
//  TransactionsFileCache.swift
//  MyFinances
//
//  Created by Артём on 07.06.2025.
//

import Foundation

// MARK: - Логика кэширования транзакций
struct TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    private let fileName: String
    
    init(fileName: String =  "transactions.json") {
        self.fileName = fileName
    }
    
    mutating func add(transaction: Transaction) throws {
        guard !transactions.contains(where: { $0.id == transaction.id }) else {
            throw FileError.duplicateId(transaction.id)
        }
        transactions.append(transaction)
    }
    
    mutating func delete(id: Int) throws {
        if let index = transactions.firstIndex(where: { $0.id == id} ) {
            transactions.remove(at: index)
        } else {
            throw FileError.transactionNotFound(id)
        }
    }
    
    func saveFile() throws {
        let jsonObjects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonObjects)
        try data.write(to: getCachePath())
    }

    mutating func downloadFile() throws {
        let data = try Data(contentsOf: getCachePath())
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [Any] else {
            return
        }
        
        try transactions = jsonObject.compactMap {
            guard let transaction = try Transaction.parse(jsonObject: $0) else {
                throw ParseError.invalidTransactionObject($0)
            }
            return transaction
        }
    }
}

// MARK: - Вспомогательные методы для работы с кэшированием транзакций
extension TransactionsFileCache {
    private func getCachePath() throws -> URL {
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw FileError.directoryNotFound
        }
        let path = directory.appendingPathComponent(fileName)
        
        return path
    }
}
