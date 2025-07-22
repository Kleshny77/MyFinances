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
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    VStack {
                        ProgressView("Загрузка категорий...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                        Text("Пожалуйста, подождите")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        categories
                    }
                }
            }
            .navigationTitle("Мои статьи")
            .searchable(text: $viewModel.searchText, prompt: "Search")
            .onAppear {
                Task { 
                    await loadCategoriesWithErrorHandling()
                }
            }
        }
        .alert("Ошибка", isPresented: $showErrorAlert) {
            Button("Ок", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadCategoriesWithErrorHandling() async {
        do {
            try await viewModel.loadCategories()
        } catch {
            errorMessage = "Ошибка загрузки категорий: \(error.localizedDescription)"
            showErrorAlert = true
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
