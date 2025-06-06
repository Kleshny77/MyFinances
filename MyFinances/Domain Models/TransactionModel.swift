//
//  TransactionModel.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import Foundation

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
    
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any],
              let id: Int = dict["id"] as? Int,
              let accountId: Int = dict["accountId"] as? Int,
              let categoryId: Int = dict["categoryId"] as? Int,
              let amountDouble: String = dict["amount"] as? String,
              let transactionDateString: String = dict["transactionDate"] as? String,
              let comment: String? = dict["comment"] as? String?,
              let createdAtString: String = dict["createdAt"] as? String,
              let updatedAtString: String = dict["updatedAt"] as? String
        else { return nil }
        
        guard let amount = Decimal(string: amountDouble) else { return nil }
        
        guard let transactionDate = Self.formatter.date(from: transactionDateString),
              let createdAt = Self.formatter.date(from: createdAtString),
              let updatedAt = Self.formatter.date(from: updatedAtString)
        else { return nil }
        
        return Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
    }
}
