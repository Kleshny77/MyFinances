//
//  ParsingHelpers.swift
//  MyFinances
//
//  Created by Артём on 13.06.2025.
//

import Foundation

// MARK: - Вспомогательные методы для парсинга
func require<T, Key: JSONKey>(_ dict: [String: Any], key: Key) throws -> T {
    guard let value = dict[key.rawValue] else {
        throw ParseError.missingField(field: key.rawValue)
    }
    guard let casted = value as? T else {
        throw ParseError.typeMismatch(field: key.rawValue, expected: "\(T.self)", actual: value)
    }
    return casted
}

func requireDecimal<Key: JSONKey>(_ dict: [String: Any], key: Key) throws -> Decimal {
    let str: String = try require(dict, key: key)
    guard let decimal = Decimal(string: str) else {
        throw ParseError.invalidDecimal(field: key.rawValue, value: str)
    }
    return decimal
}

func requireDate<Key: JSONKey>(_ dict: [String: Any], key: Key, formatter: ISO8601DateFormatter = DateFormatterFactory.iso8601) throws -> Date {
    let str: String = try require(dict, key: key)
    guard let date = formatter.date(from: str) else {
        throw ParseError.invalidDate(field: key.rawValue, value: str)
    }
    return date
}

func require<T, Key: JSONKey>(_ columns: [String: String], key: Key, transform: (String) -> T?) throws -> T {
    guard let raw = columns[key.rawValue] else {
        throw ParseError.missingField(field: key.rawValue)
    }
    guard let value = transform(raw) else {
        throw ParseError.typeMismatch(field: key.rawValue, expected: "\(T.self)", actual: raw)
    }
    return value
}
