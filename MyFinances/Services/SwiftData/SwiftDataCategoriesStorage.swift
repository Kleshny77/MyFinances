//
//  SwiftDataCategoriesStorage.swift
//  MyFinances
//
//  Created by Артём on 19.07.2025.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataCategoriesStorage: CategoriesStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() throws {
        let schema = Schema([
            LocalTransaction.self,
            BackupOperation.self,
            LocalAccount.self,
            LocalCategory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema)
        self.modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        self.modelContext = ModelContext(modelContainer)
    }
    
    func getAllCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<LocalCategory>()
        let localCategories = try modelContext.fetch(descriptor)
        return localCategories.map { $0.toCategory() }
    }
    
    func saveCategories(_ categories: [Category]) async throws {
        try await clearAll()
        for category in categories {
            let localCategory = LocalCategory(from: category)
            modelContext.insert(localCategory)
        }
        try modelContext.save()
    }
    
    func clearAll() async throws {
        let descriptor = FetchDescriptor<LocalCategory>()
        let localCategories = try modelContext.fetch(descriptor)
        for localCategory in localCategories {
            modelContext.delete(localCategory)
        }
        try modelContext.save()
    }
} 