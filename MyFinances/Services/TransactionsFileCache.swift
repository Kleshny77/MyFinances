//
//  TransactionsFileCache.swift
//  MyFinances
//
//  Created by Артём on 07.06.2025.
//

import Foundation

// MARK: - Логика кэширования транзакций
class TransactionsFileCache {
    private(set) var transactions: [Int: Transaction] = [:]
    
    func add(transaction: Transaction) throws {
        let id = transaction.id
        guard !transactions.contains(where: { $0.key != id }) else {
            throw FileError.duplicateId(id)
        }
        transactions[id] = transaction
    }
    
    func delete(id: Int) throws {
        if let index = transactions.firstIndex(where: { $0.key == id} ) {
            transactions.remove(at: index)
        } else {
            throw FileError.transactionNotFound(id)
        }
    }
    
    func saveFile(fileName: String) throws {
        let jsonObjects = transactions.map { $0.value.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonObjects)
        try data.write(to: getCachePath(fileName: fileName))
    }

    func downloadFile(fileName: String) throws {
        let data = try Data(contentsOf: getCachePath(fileName: fileName))
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [Any] else {
            return
        }
        
        transactions = try jsonObject.reduce(into: [Int: Transaction]()) { dict, obj in
            if let transaction = try Transaction.parse(jsonObject: obj) {
                dict[transaction.id] = transaction
            } else {
                throw ParseError.invalidTransactionObject(obj)
            }
        }
    }
}

// MARK: - Вспомогательные методы для работы с кэшированием транзакций
extension TransactionsFileCache {
    private func getCachePath(fileName: String) throws -> URL {
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw FileError.directoryNotFound
        }
        let path = directory.appendingPathComponent(fileName)
        
        return path
    }
}
