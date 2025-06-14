//
//  ServersError.swift
//  MyFinances
//
//  Created by Артём on 14.06.2025.
//

import Foundation

// MARK: - Ошибки, связанные с ответом бекэнда
enum ServersError: Error {
    case emptyAccountsList, emptyCategoriesList, emptyTransactionsList
}

// MARK: - Описание ошибок
extension ServersError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyAccountsList:
            return "Сервер вернул пустой список счетов"
        case .emptyCategoriesList:
            return "Сервер вернул пустой список категорий"
        case .emptyTransactionsList:
            return "Сервер вернул пустой список операций"
        }
        
    }
}
