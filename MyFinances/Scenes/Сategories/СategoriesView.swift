//
//  СategoriesView.swift
//  MyFinances
//
//  Created by Артём on 03.07.2025.
//

import Foundation
import SwiftUI

struct СategoriesView: View {
    @StateObject var viewModel: СategoriesViewModel
    
    var body: some View {
        NavigationView {
            List {
                categories
            }
            .navigationTitle("Мои статьи")
            .searchable(text: $viewModel.searchText, prompt: "Search")
            .onAppear {
                Task { await viewModel.loadCategories() }
            }
        }
    }
    
    private var categories: some View {
        Section(header: Text("Статьи")) {
            ForEach(viewModel.filteredCategories, id: \.id) { category in
                CategoryView(category: category)
                    .listRowInsets(EdgeInsets())
            }
        }
    }
}
