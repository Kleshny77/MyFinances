//
//  NetworkError.swift
//  MyFinances
//
//  Created by Артём on 18.07.2025.
//

import Foundation

enum NetworkError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case httpError(code: Int, data: Data)
    case invalidResponse
    case network(Error)
}

// MARK: - Описание ошибок
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Ошибка кодирования данных: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Ошибка декодирования данных: \(error.localizedDescription)"
        case .httpError(let code, _):
            return "HTTP ошибка: \(code)"
        case .invalidResponse:
            return "Неверный ответ сервера"
        case .network(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        }
    }
}
