//
//  TransactionsFileCache.swift
//  MyFinances
//
//  Created by Артём on 07.06.2025.
//

import Foundation

// MARK: - Логика кэширования транзакций
final class TransactionsFileCache {
    private static var storage: [Int: Transaction] = [:]
    
    var transactions: [Int: Transaction] {
        get { Self.storage }
        set { Self.storage = newValue }
    }
    
    func add(transaction: Transaction) throws {
        let id = transaction.id
        guard transactions[id] == nil else { throw FileError.duplicateId(id) }
        transactions[id] = transaction
    }
    
    func delete(id: Int) throws {
        guard transactions.removeValue(forKey: id) != nil else {
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
        let any = try JSONSerialization.jsonObject(with: data)
        guard let json = any as? [Any] else {
            throw ParseError.typeMismatch(field: fileName, expected: "[Any]", actual: any)
        }
        let dict = try json.reduce(into: [Int: Transaction]()) { res, obj in
            let trx = try Transaction.parse(jsonObject: obj)
            res[trx.id] = trx
        }
        transactions = dict
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
