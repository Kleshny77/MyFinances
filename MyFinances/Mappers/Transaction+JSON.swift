//
//  Transaction+Serialization.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сериализация и десериализация Transaction
extension Transaction: JSONSerializable {
    var jsonObject: [String: Any] {
        var dict: [String: Any] = [
            TransactionCases.id.rawValue: id,
            TransactionCases.account.rawValue: account.jsonObject,
            TransactionCases.category.rawValue: category.jsonObject,
            TransactionCases.amount.rawValue: String(describing: amount),
            TransactionCases.transactionDate.rawValue: DateFormatterFactory.iso8601.string(from: transactionDate),
            TransactionCases.createdAt.rawValue: DateFormatterFactory.iso8601.string(from: createdAt),
            TransactionCases.updatedAt.rawValue: DateFormatterFactory.iso8601.string(from: updatedAt)
        ]
        if let comment { dict[TransactionCases.comment.rawValue] = comment }
        
        return dict
    }
    
    static func parse(jsonObject: Any) throws -> Transaction {
        guard let dict = jsonObject as? [String: Any] else {
            throw ParseError.typeMismatch(field: "Transaction", expected: "[String: Any]", actual: jsonObject)
        }
        
        return Transaction(
            id: try require(dict, key: TransactionCases.id),
            account: try BankAccount.parse(jsonObject: try require(dict, key: TransactionCases.account)),
            category: try Category.parse(jsonObject: try require(dict, key: TransactionCases.category)),
            amount: try requireDecimal(dict, key: TransactionCases.amount),
            transactionDate: try requireDate(dict, key: TransactionCases.transactionDate),
            comment: dict[TransactionCases.comment.rawValue] as? String,
            createdAt: try requireDate(dict, key: TransactionCases.createdAt),
            updatedAt: try requireDate(dict, key: TransactionCases.updatedAt)
        )
    }
}
