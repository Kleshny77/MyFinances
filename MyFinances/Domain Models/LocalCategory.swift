//
//  LocalCategory.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class LocalCategory {
    var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    convenience init(from category: Category) {
        self.init(
            id: category.id,
            name: category.name,
            emoji: String(category.emoji),
            isIncome: category.isIncome
        )
    }
    
    func toCategory() -> Category {
        return Category(
            id: id,
            name: name,
            emoji: emoji.first ?? "📁",
            isIncome: isIncome
        )
    }
} 