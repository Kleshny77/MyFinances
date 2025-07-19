//
//  CategoriesService.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Сервис для работы с категориями
@MainActor
struct CategoriesService {
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
    
    // MARK: - Асинхронная версия с локальным хранением
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
            let networkCategories = try await fetchFromNetwork()
            
            do {
                try await localStorage.saveCategories(networkCategories)
            } catch {
            }
            
            return networkCategories
            
        } catch {
            do {
                return try await localStorage.getAllCategories()
            } catch {
                return []
            }
        }
    }
    
    func fetchCategories(direction: Direction) async throws -> [Category] {
        do {
            let networkCategories = try await fetchFromNetworkByDirection(direction: direction)
            
            do {
                let allCategories = try await localStorage.getAllCategories()
                _ = allCategories.filter { $0.isIncome == (direction == .income) }
                
                let updatedCategories = allCategories.map { category in
                    if let networkCategory = networkCategories.first(where: { $0.id == category.id }) {
                        return networkCategory
                    }
                    return category
                }
                
                try await localStorage.saveCategories(updatedCategories)
            } catch {
            }
            
            return networkCategories
            
        } catch {
            do {
                let allCategories = try await localStorage.getAllCategories()
                return allCategories.filter { $0.isIncome == (direction == .income) }
            } catch {
                return []
            }
        }
    }
    
    // MARK: - Приватные методы
    private func fetchFromNetwork() async throws -> [Category] {
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.categories)!
        
        let categoriesAPI: [CategoryAPI] = try await networkClient.request(url: url)
        
        guard !categoriesAPI.isEmpty else {
            throw ServersError.emptyCategoriesList
        }
        
        return categoriesAPI.map { $0.toDomain() }
    }
    
    private func fetchFromNetworkByDirection(direction: Direction) async throws -> [Category] {
        let isIncome = direction == .income
        let url = URL(string: NetworkConstants.fullBaseURL + NetworkConstants.Endpoints.categoriesByType + "/\(isIncome)")!
        
        let categoriesAPI: [CategoryAPI] = try await networkClient.request(url: url)
        
        guard !categoriesAPI.isEmpty else {
            throw ServersError.emptyCategoriesList
        }
        
        return categoriesAPI.map { $0.toDomain() }
    }
}
