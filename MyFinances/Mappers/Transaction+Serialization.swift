//
//  Transaction+Serialization.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Возможные (и необходимые) поля в заголовке CSV
enum CSVParse: String {
    case id
    case accountId
    case categoryId
    case amount
    case transactionDate
    case comment
    case createdAt
    case updatedAt
}

// MARK: - Преобразование транзакций в json и csv (и обратно)
extension Transaction {
    private static let formatter = ISO8601DateFormatter()
    
    var jsonObject: Any {
        [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": String(describing: amount),
            "transactionDate": Self.formatter.string(from: transactionDate),
            "comment": comment ?? NSNull(), // Как вернуть опциональное значение коммента в json?
            "createdAt": Self.formatter.string(from: createdAt),
            "updatedAt": Self.formatter.string(from: updatedAt)
        ]
    }
    
    static func parse(jsonObject: Any) throws -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else {
            throw ParseError.typeMismatch(field: "jsonObject", expected: "[String: Any]", actual: jsonObject)
        }

        let id: Int = try require(dict, key: "id")
        let accountId: Int = try require(dict, key: "accountId")
        let categoryId: Int = try require(dict, key: "categoryId")
        let amount: Decimal = try requireDecimal(dict, key: "amount")
        let transactionDate: Date = try requireDate(dict, key: "transactionDate")
        let createdAt: Date = try requireDate(dict, key: "createdAt")
        let updatedAt: Date = try requireDate(dict, key: "updatedAt")
        let commentRaw = dict["comment"]
        let comment = (commentRaw is NSNull || commentRaw == nil) ? nil : (commentRaw as? String)

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func parse(csvObject: Any) throws -> Transaction {
        let separator = ","
        
        guard let csvString = csvObject as? String else {
            throw ParseError.typeMismatch(field: "csvObject", expected: "String", actual: csvObject)
        }
        
        let rows = csvString
            .components(separatedBy: "\n")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard let header = rows.first?.components(separatedBy: separator),
              let values = rows.dropFirst().first?.components(separatedBy: separator) else {
            throw ParseError.generic("CSV-файл должен содержать как минимум заголовок и одну строку данных")
        }
        
        let columns = Dictionary(uniqueKeysWithValues: zip(header, values))
        
        let id = try require(columns, key: .id, transform: Int.init)
        let accountId = try require(columns, key: .accountId, transform: Int.init)
        let categoryId = try require(columns, key: .categoryId, transform: Int.init)
        
        let amountStr = try require(columns, key: .amount) { $0.isEmpty ? nil : $0 }
        guard let amount = Decimal(string: amountStr) else {
            throw ParseError.invalidDecimal(field: "amount", value: amountStr)
        }
        
        let transactionDate = try require(columns, key: .transactionDate, transform: formatter.date)
        let createdAt = try require(columns, key: .createdAt, transform: formatter.date)
        let updatedAt = try require(columns, key: .updatedAt, transform: formatter.date)
        let comment = columns[CSVParse.comment.rawValue]
        let finalComment = (comment?.isEmpty == true) ? nil : comment
        
        return Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount,
                           transactionDate: transactionDate, comment: finalComment,
                           createdAt: createdAt, updatedAt: updatedAt)
    }
}


// MARK: - Вспомогательные методы для работы парсингом в json и csv
extension Transaction {
    // MARK: - Проверка и извлечение поля по ключу из [String: Any] (для json)
    private static func require<T>(_ dict: [String: Any], key: String) throws -> T {
        guard let value = dict[key] else {
            throw ParseError.missingField(field: key)
        }
        guard let casted = value as? T else {
            throw ParseError.typeMismatch(field: key, expected: "\(T.self)", actual: value)
        }
        return casted
    }
    
    // MARK: - Извлечение и преобразование поля к Decimal
    private static func requireDecimal(_ dict: [String: Any], key: String) throws -> Decimal {
        let str: String = try require(dict, key: key)
        guard let decimal = Decimal(string: str) else {
            throw ParseError.invalidDecimal(field: key, value: str)
        }
        return decimal
    }
    
    // MARK: - Извлечение и преобразование поля к Date
    private static func requireDate(_ dict: [String: Any], key: String) throws -> Date {
        let str: String = try require(dict, key: key)
        guard let date = formatter.date(from: str) else {
            throw ParseError.invalidDate(field: key, value: str)
        }
        return date
    }
    
    // MARK: - Проверка и извлечение значения из CSV с преобразованием типа
    private static func require<T>(_ columns: [String: String], key: CSVParse, transform: (String) -> T?) throws -> T {
        guard let raw = columns[key.rawValue] else {
            throw ParseError.missingField(field: key.rawValue)
        }
        guard let value = transform(raw) else {
            throw ParseError.typeMismatch(field: key.rawValue, expected: "\(T.self)", actual: raw)
        }
        return value
    }
}
