//
//  TransactionsFileCache.swift
//  MyFinances
//
//  Created by Артём on 07.06.2025.
//

import Foundation

// MARK: - Логика кэширования транзакций
class TransactionsFileCache {
    // В качестве коллекции выбран словарь для улучшенной оптимизации (вставка и удаление за O(1)), а не массив (вставка и удаление за O(n))
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
    
    func saveTransactions(fileName: String) throws {
        let jsonObjects = transactions.map { $0.value.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: jsonObjects)
        try data.write(to: getCachePath(fileName: fileName))
    }

    func loadTransactions(fileName: String) throws {
        let data = try Data(contentsOf: getCachePath(fileName: fileName))
        let jsonAny = try JSONSerialization.jsonObject(with: data)
        guard let jsonObject = jsonAny as? [Any] else {
            throw ParseError.typeMismatch(field: fileName, expected: "[Any]", actual: jsonAny)
        }
        
        transactions = try jsonObject.reduce(into: [Int: Transaction]()) { dict, obj in
            let transaction = try Transaction.parse(jsonObject: obj)
            dict[transaction.id] = transaction
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
