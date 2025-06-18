//
//  Transaction+CSV.swift
//  MyFinances
//
//  Created by Артём on 14.06.2025.
//

import Foundation

// MARK: - Преобразование Transaction в csv (и обратно)
extension Transaction {
    static let sep = ","
    
    var csvString: String {
        let header = TransactionCases.allCases.map { $0.rawValue }.joined(separator: Self.sep)
        let row = [
            String(id),
            String(account.id),
            String(category.id),
            String(describing: amount),
            DateFormatterFactory.iso8601.string(from: transactionDate),
            comment  ?? "",
            DateFormatterFactory.iso8601.string(from: createdAt),
            DateFormatterFactory.iso8601.string(from: updatedAt)
        ].joined(separator: Self.sep)
        
        return header + "\n" + row
    }
    
    static func parse(csv: String) throws -> Transaction {
        let lines = csv.split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
        guard lines.count > 1 else {
            throw ParseError.generic("CSV не содержит строку данных")
        }

        let header = lines[0].components(separatedBy: sep)
        let values = lines[1].components(separatedBy: sep)
        let columns = Dictionary(uniqueKeysWithValues: zip(header, values))
        
        let id: Int = try require(columns, key: TransactionCases.id, transform: Int.init)
        let accountId: Int = try require(columns, key: TransactionCases.account, transform: Int.init)
        let categoryId: Int = try require(columns, key: TransactionCases.category, transform: Int.init)
        let amount: Decimal = try require(columns, key: TransactionCases.amount) { Decimal(string: $0) }
        let transactionDate: Date = try require(columns, key: TransactionCases.transactionDate) {
            DateFormatterFactory.iso8601.date(from: $0)
        }
        let commentRaw = columns[TransactionCases.comment.rawValue]
        let comment = (commentRaw?.isEmpty == true ? nil : commentRaw)
        let createdAt: Date = try require(columns, key: TransactionCases.createdAt) {
            DateFormatterFactory.iso8601.date(from: $0)
        }
        let updatedAt: Date = try require(columns, key: TransactionCases.updatedAt) {
            DateFormatterFactory.iso8601.date(from: $0)
        }
        
        let account  = BankAccount(id: accountId)
        let category = Category(id: categoryId)
        
        return Transaction(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Дополнительный инициализатор Category для использования в парсинге из CSV
extension Category {
    init(id: Int) {
        self.id = id
        self.name = ""
        self.emoji = " "
        self.isIncome = false
    }
}

// MARK: - Дополнительный инициализатор BankAccount для использования в парсинге из CSV
extension BankAccount {
    init(id: Int) {
        self.id = id
        self.userId = 0
        self.name = ""
        self.balance = 0
        self.currency = ""
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

