//
//  ParseError.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Ошибки преобразования объектов в json и csv
enum ParseError: Error {
    case typeMismatch(field: String, expected: String, actual: Any)
    case missingField(field: String)
    case invalidDecimal(field: String, value: String)
    case invalidDate(field: String, value: String)
    case invalidTransactionObject(Any)
    case generic(String)
}

// MARK: - Описание ошибок
extension ParseError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .typeMismatch(let field, let expected, let actual):
            return "Ожидался тип \(expected) в поле '\(field)', но получено: \(actual)"
        case .missingField(let field):
            return "Отсутствует обязательное поле: \(field)"
        case .invalidDecimal(let field, let value):
            return "Не удалось распарсить Decimal в поле '\(field)' из строки: '\(value)'"
        case .invalidDate(let field, let value):
            return "Не удалось распарсить дату в поле '\(field)' из строки: '\(value)'"
        case .invalidTransactionObject(let obj):
            return "Объект транзакции некорректен: \(obj)"
        case .generic(let message):
            return message
        }
    }
}
