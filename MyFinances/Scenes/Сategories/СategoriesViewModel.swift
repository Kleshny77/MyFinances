//
//  СategoriesViewModel.swift
//  MyFinances
//
//  Created by Артём on 03.07.2025.
//

import Foundation

@MainActor
class СategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var searchText: String = ""
    @Published var isLoading = false

    private var service: CategoriesService?
    
    var filteredCategories: [Category] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return categories
        }

        let names = categories.map { $0.name }
        let matchedNames = FuzzySearch.search(searchText, in: names)
        
        return categories.filter { matchedNames.contains($0.name) }
    }
    
    init() {
        Task {
            do {
                try await initializeService()
                try await loadCategories()
            } catch {
            }
        }
    }
    
    private func initializeService() async throws {
        service = await CategoriesService.createWithLocalStorage()
    }
    
    func loadCategories() async throws {
        guard let service = service else {
            let fallbackService = CategoriesService.create()
            categories = try await fallbackService.fetchCategories()
            return
        }
        
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
            }
        }
    }
}
