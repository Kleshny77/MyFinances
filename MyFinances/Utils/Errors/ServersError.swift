//
//  ServersError.swift
//  MyFinances
//
//  Created by Артём on 14.06.2025.
//

import Foundation

enum ServersError: Error {
    case emptyAccountsList
}

extension ServersError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyAccountsList:
            return "Сервер вернул пустой список счетов"
        }
    }
}
