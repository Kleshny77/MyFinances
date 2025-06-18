//
//  Category+Serialization.swift
//  MyFinances
//
//  Created by Артём on 13.06.2025.
//

import Foundation

// MARK: - Сериализация и десериализация Category
extension Category: JSONSerializable {
    var jsonObject: [String: Any] {
        [
            CategoryCases.id.rawValue: id,
            CategoryCases.name.rawValue: name,
            CategoryCases.emoji.rawValue: String(emoji),
            CategoryCases.isIncome.rawValue: isIncome
        ]
    }
    
    static func parse(jsonObject: Any) throws -> Category {
        guard let dict = jsonObject as? [String: Any] else {
            throw ParseError.typeMismatch(field: "Category", expected: "[String: Any]", actual: jsonObject)
        }
        let id: Int = try require(dict, key: CategoryCases.id)
        let name: String = try require(dict, key: CategoryCases.name)
        let isIncome: Bool = try require(dict, key: CategoryCases.isIncome)
        let emojiString: String = try require(dict, key: CategoryCases.emoji)
        guard let emoji = emojiString.first else {
            throw ParseError.typeMismatch(field: "emoji", expected: "Character", actual: emojiString)
        }
        
        return Category(id: id, name: name, emoji: emoji, isIncome: isIncome)
    }
}
