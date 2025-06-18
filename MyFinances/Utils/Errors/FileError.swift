//
//  FileError.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation

// MARK: - Ошибки, связанные с работой с файловой системой
enum FileError: Error {
    case directoryNotFound
    case duplicateId(Int)
    case transactionNotFound(Int)
}

// MARK: - Описание ошибок
extension FileError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "Не удалось найти директорию"
        case .duplicateId(let id):
            return "Операция с id=\(id) уже существует в кэше"
        case .transactionNotFound(let id):
            return "Операция с id=\(id) не найдена в кэше"
        }
    }
}
