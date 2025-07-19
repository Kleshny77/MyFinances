//
//  NetworkConstants.swift
//  MyFinances
//
//  Created by Артём on 18.07.2025.
//

import Foundation

// MARK: - Константы для сетевых запросов
enum NetworkConstants {
    // MARK: - Базовые URL и токен
    static let baseURL = "https://shmr-finance.ru"
    static let apiPath = "/api/v1"
    static let fullBaseURL = baseURL + apiPath
    static let authToken = "cHCvtayiE5dro9mSxw2bM8r5"
    
    // MARK: - Пути API
    enum Endpoints {
        static let accounts = "/accounts"
        static let categories = "/categories"
        static let categoriesByType = "/categories/type"
        static let transactions = "/transactions"
        static let transactionsByAccount = "/transactions/account"
    }
    
    // MARK: - HTTP заголовки
    enum Headers {
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let bearerPrefix = "Bearer "
        static let jsonContentType = "application/json"
    }
    
    // MARK: - HTTP методы
    enum Methods {
        static let get = "GET"
        static let post = "POST"
        static let put = "PUT"
        static let delete = "DELETE"
    }
    
    // MARK: - Параметры запросов
    enum QueryParams {
        static let startDate = "startDate"
        static let endDate = "endDate"
    }
} 