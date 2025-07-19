//
//  СategoriesViewModel.swift
//  MyFinances
//
//  Created by Артём on 03.07.2025.
//

import Foundation
import Ifrit

@MainActor
class СategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var searchText: String = ""
    @Published var isLoading = false

    private let service = CategoriesService.create()
    
    var filteredCategories: [Category] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return categories
        }

        let names = categories.map { $0.name }
        let matchedNames = FuzzySearch.search(searchText, in: names)
        
        return categories.filter { matchedNames.contains($0.name) }
    }
    
    func loadCategories() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            categories = try await service.fetchCategories()
        } catch {
            categories = []
        }
    }

    init() {
        Task {
            do {
                try await loadCategories()
            } catch {
                // Ошибка при инициализации - категории будут загружены позже
            }
        }
    }
}
