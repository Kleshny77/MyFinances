//
//  Protocols.swift
//  MyFinances
//
//  Created by Артём on 13.06.2025.
//

import Foundation

// MARK: - Протокол для ключей JSON-объекта
protocol JSONKey {
    var rawValue: String { get }
}

// MARK: - Протокол для объектов, поддерживающих конвертацию в и из JSON 
protocol JSONSerializable {
    var jsonObject: [String: Any] { get }
    static func parse(jsonObject: Any) throws -> Self
}
