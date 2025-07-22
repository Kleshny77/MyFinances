//
//  CategoriesService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с категориями
struct CategoriesService {
    func fetchCategories() async throws -> [Category] {
        let raw: [[String: Any]] = [
            [
                "id": 1,
                "name": "Зарплата",
                "emoji": "💰",
                "isIncome": true
            ],
            [
                "id": 2,
                "name": "Еда",
                "emoji": "🍔",
                "isIncome": false
            ],
            [
                "id": 3,
                "name": "Транспорт",
                "emoji": "🚗",
                "isIncome": false
            ],
            [
                "id": 4,
                "name": "Кафе",
                "emoji": "🧑‍🍳",
                "isIncome": false
            ],
            [
                "id": 5,
                "name": "Образование",
                "emoji": "🧑‍🏫",
                "isIncome": false
            ],
            [
                "id": 6,
                "name": "Жилье",
                "emoji": "🏠",
                "isIncome": false
            ],
        ]
        
        guard !raw.isEmpty else {
            throw ServersError.emptyCategoriesList
        }
        let categories = try raw.map { try Category.parse(jsonObject: $0) }
        
        return categories
    }
    
    func fetchCategories(direction: Direction) async throws -> [Category] {
        // потом заменить на отдельный запрос на бэк, не через fetchCategories()
        let categories = try await fetchCategories()
        
        switch direction {
        case .income:
            return categories.filter { $0.isIncome }
        case .outcome:
            return categories.filter { !$0.isIncome }
        }
    }
}
