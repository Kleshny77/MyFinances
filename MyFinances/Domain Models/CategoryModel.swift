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
