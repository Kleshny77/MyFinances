//
//  CategoryModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

// MARK: - Статус операции
enum Direction {
    case income
    case outcome
}

// MARK: - Модель категории
struct Category: Equatable {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Bool
}

// MARK: - Модель категории для API (JSON)
struct CategoryAPI: Codable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
    
    func toDomain() -> Category {
        return Category(
            id: id,
            name: name,
            emoji: emoji.first ?? "📁",
            isIncome: isIncome
        )
    }
}
