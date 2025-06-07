//
//  TransactionModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

//enum CSVParse: Int {
//    case id
//    case accountId
//    case categoryId
//    case amount
//    case transactionDate
//    case comment
//    case createdAt
//    case updatedAt
//}

enum CSVParse: String {
    case id
    case accountId
    case categoryId
    case amount
    case transactionDate
    case comment
    case createdAt
    case updatedAt
}

struct Transaction: Codable {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
}

extension Transaction {
    private static let formatter = ISO8601DateFormatter()
    
    var jsonObject: Any {
        let json: [String : Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": String(describing: amount),
            "transactionDate": Self.formatter.string(from: transactionDate),
            "comment": comment ?? NSNull(),
            "createdAt": Self.formatter.string(from: createdAt),
            "updatedAt": Self.formatter.string(from: updatedAt),
        ]
        
        return json
    }
    
    var csvObject: Any {
        return 0
    }
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any],
              let id: Int = dict["id"] as? Int,
              let accountId: Int = dict["accountId"] as? Int,
              let categoryId: Int = dict["categoryId"] as? Int,
              let amountString: String = dict["amount"] as? String,
              let transactionDateString: String = dict["transactionDate"] as? String,
              let comment: String? = dict["comment"] as? String?,
              let createdAtString: String = dict["createdAt"] as? String,
              let updatedAtString: String = dict["updatedAt"] as? String
        else {
            print("ошибка каста jsonObject")
            return nil
        }
        
        guard let amount = Decimal(string: amountString)
        else {
            print("amount из json не кастится к Decimal")
            return nil
        }
        
        guard let transactionDate = Self.formatter.date(from: transactionDateString),
              let createdAt = Self.formatter.date(from: createdAtString),
              let updatedAt = Self.formatter.date(from: updatedAtString)
        else {
            print("ошибка каста date из json")
            return nil
        }
        
        return Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    
    static func parse(csvObject: Any) -> Transaction? {
        let separator = ","
        
        guard let csvString = csvObject as? String
        else {
            print("ошибка каста csvString в String")
            return nil
        }
        
        let csvArr = csvString.components(separatedBy: "\n")
        guard let header = csvArr.first?.components(separatedBy: separator) else { return nil }
        
        var columnIndexMap: [String: Int] = [:]
        for (index, columnName) in header.enumerated() {
            columnIndexMap[String(columnName)] = index
        }
        
        guard let firstRow = csvArr.dropFirst().first else {
            return nil
        }
        let values = firstRow.components(separatedBy: separator)
        
        func value(for key: CSVParse) -> String? {
            guard let index = columnIndexMap[key.rawValue], index < values.count else { return nil }
            return values[index]
        }
        
        guard let idStr = value(for: .id), let id = Int(idStr),
              let accountIdStr = value(for: .accountId), let accountId = Int(accountIdStr),
              let categoryIdStr = value(for: .categoryId), let categoryId = Int(categoryIdStr),
              let amountStr = value(for: .amount), let amount = Decimal(string: amountStr),
              let transactionDateStr = value(for: .transactionDate), let transactionDate =  Self.formatter.date(from: transactionDateStr),
              let createdAtStr = value(for: .createdAt), let createdAt =  Self.formatter.date(from: createdAtStr),
              let updatedAtStr = value(for: .updatedAt), let updatedAt =  Self.formatter.date(from: updatedAtStr)
        else { return nil }
        let comment = value(for: .comment)
        
        return Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
    }
}
