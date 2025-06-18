//
//  BankAccount+Serialization.swift
//  MyFinances
//
//  Created by Артём on 13.06.2025.
//

import Foundation

// MARK: - Сериализация и десериализация BankAccount
extension BankAccount: JSONSerializable {
    var jsonObject: [String: Any] {
        [
            BankAccountCases.id.rawValue: id,
            BankAccountCases.userId.rawValue: userId,
            BankAccountCases.name.rawValue: name,
            BankAccountCases.balance.rawValue: String(describing: balance),
            BankAccountCases.currency.rawValue: currency,
            BankAccountCases.createdAt.rawValue: DateFormatterFactory.iso8601.string(from: createdAt),
            BankAccountCases.updatedAt.rawValue: DateFormatterFactory.iso8601.string(from: updatedAt)
        ]
    }
    
    static func parse(jsonObject: Any) throws -> BankAccount {
        guard let dict = jsonObject as? [String: Any] else {
            throw ParseError.typeMismatch(field: "BankAccount", expected: "[String: Any]", actual: jsonObject)
        }
        
        return BankAccount(
            id: try require(dict, key: BankAccountCases.id),
            userId: try require(dict, key: BankAccountCases.userId),
            name: try require(dict, key: BankAccountCases.name),
            balance: try requireDecimal(dict, key: BankAccountCases.balance),
            currency: try require(dict, key: BankAccountCases.currency),
            createdAt: try requireDate(dict, key: BankAccountCases.createdAt),
            updatedAt: try requireDate(dict, key: BankAccountCases.updatedAt)
        )
    }
}
