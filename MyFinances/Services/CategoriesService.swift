//
//  CategoriesService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

struct CategoriesService {
    func fetchCategories() async throws -> [Category] {
        let categories = [
            Category(id: 1, name: "Образование", emoji: "📚", isIncome: false),
            Category(id: 2, name: "Зарплата", emoji: "💰", isIncome: true),
            Category(id: 3, name: "Премия", emoji: "🤑", isIncome: true),
            Category(id: 4, name: "Еда", emoji: "🍕", isIncome: false),
            Category(id: 5, name: "Коммунальные услуги", emoji: "🔌", isIncome: false)
        ]
        
        return categories
    }
    
    func fetchCategories(direction: Direction) async throws -> [Category] {
        // потом заменить на отдельный запрос в бд, не через fetchCategories()
        let categories = try await fetchCategories()
        
        switch direction {
        case .income:
            return categories.filter { $0.isIncome }
        case .outcome:
            return categories.filter { !$0.isIncome }
        }
    }
}
