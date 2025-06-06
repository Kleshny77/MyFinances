//
//  CategoryModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

enum Direction {
    case income
    case outcome
}

struct Category {
    let id: Int
    let name: String
    let emoji: Character
    let isIncome: Bool
}
