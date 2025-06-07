//
//  TransactionsFileCache.swift
//  MyFinances
//
//  Created by Артём on 07.06.2025.
//

import Foundation

enum FileError: Error {
    case directoryNotFound
    case parsingFailed
}

struct TransactionsFileCache {
    private(set) var transactions: [Transaction]
    
    mutating func add(transaction: Transaction) {
        transactions.append(transaction)
    }
    
    mutating func delete(id: Int) {
        if let index = transactions.firstIndex(where: { $0.id == id} ) {
            transactions.remove(at: index)
        }
    }
    
    func saveFile() {
        let jsonObjects = transactions.map { $0.jsonObject }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonObjects)
            try data.write(to: getCachePath())
        } catch FileError.directoryNotFound {
            print("директория не найдена")
        } catch {
            print(error)
        }
    }
    
    mutating func downloadFile() {
        do {
            let data = try Data(contentsOf: getCachePath())
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [Any] else { throw FileError.parsingFailed }
            transactions = jsonObject.compactMap {
                guard let transaction = Transaction.parse(jsonObject: $0) else {
                    print("Ошибка парсинга транзакции: \($0)")
                    return nil
                }
                return transaction
            }
        } catch FileError.directoryNotFound {
            print("директория не найдена")
        } catch FileError.parsingFailed {
            print("Парсинг завершился ошибкой")
        } catch {
            print(error)
        }
    }
    
    private func getCachePath() throws -> URL {
        let fileName = "transactions.json"
        
        guard let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else {
            print("Не удалось получить путь к кэшу")
            throw FileError.directoryNotFound
        }
        
        let path = directory.appendingPathComponent(fileName)
        return path
    }
}
