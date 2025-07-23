//
//  CategoriesService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с категориями
@MainActor
final class CategoriesService {
    private let networkClient: NetworkClient
    private let localStorage: CategoriesStorage
    
    init(networkClient: NetworkClient, localStorage: CategoriesStorage) {
        self.networkClient = networkClient
        self.localStorage = localStorage
    }
    
    // MARK: - Фабричный метод для создания сервиса с дефолтным NetworkClient
    static func create() -> CategoriesService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        return CategoriesService(networkClient: networkClient, localStorage: MockCategoriesStorage())
    }
    
    static func createWithLocalStorage() async -> CategoriesService {
        let networkClient = NetworkClient(token: NetworkConstants.authToken)
        do {
            let localStorage = try SwiftDataCategoriesStorage()
            return CategoriesService(networkClient: networkClient, localStorage: localStorage)
        } catch {
            return CategoriesService(networkClient: networkClient, localStorage: MockCategoriesStorage())
        }
    }
    
    func fetchCategories() async throws -> [Category] {
        do {
            let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.categories)!
            let response: [CategoryAPI] = try await networkClient.request(url: url)
            let categories = response.map { $0.toDomain() }
            do { try await localStorage.saveCategories(categories) } catch {}
            return categories
        } catch {
            do { return try await localStorage.getAllCategories() } catch { return [] }
        }
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
