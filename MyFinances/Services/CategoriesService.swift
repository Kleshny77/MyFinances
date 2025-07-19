//
//  CategoriesService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с категориями
struct CategoriesService {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    // MARK: - Фабричный метод для создания сервиса с дефолтным NetworkClient
    static func create() -> CategoriesService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        return CategoriesService(networkClient: networkClient)
    }
    
    func fetchCategories() async throws -> [Category] {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.categories)!
        
        let categoriesAPI: [CategoryAPI] = try await networkClient.request(url: url)
        
        guard !categoriesAPI.isEmpty else {
            throw ServersError.emptyCategoriesList
        }
        
        return categoriesAPI.map { $0.toDomain() }
    }
    
    func fetchCategories(direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.categoriesByType + "/\(isIncome)")!
        
        let categoriesAPI: [CategoryAPI] = try await networkClient.request(url: url)
        
        guard !categoriesAPI.isEmpty else {
            throw ServersError.emptyCategoriesList
        }
        
        return categoriesAPI.map { $0.toDomain() }
    }
}
