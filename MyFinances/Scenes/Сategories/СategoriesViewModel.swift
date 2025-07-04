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
    private let fuse = Fuse()
    
    private let service = CategoriesService()
    
    var filteredCategories: [Category] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return categories
        }
        
        let pattern = fuse.createPattern(from: searchText)
        
        return categories
            .compactMap { category -> (Category, Double)? in
                if let hit = fuse.search(pattern, in: category.name) {
                    return (category, hit.score)
                }
                return nil
            }
            .sorted { $0.1 < $1.1 }
            .map(\.0)
    }
    
    func loadCategories() async {
        do {
            categories = try await service.fetchCategories()
        } catch {
            print("Error loading categories: \(error)")
        }
    }
}
