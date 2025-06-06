//
//  MyFinancesTests.swift
//  MyFinancesTests
//
//  Created by Артём on 06.06.2025.
//

import XCTest
@testable import MyFinances

final class MyFinancesTests: XCTestCase {
    
    func testParse_Normal() {
        let jsonObject = validTransactionJSON()
        
        guard let transaction = Transaction.parse(jsonObject: jsonObject) else {
            XCTFail("Transaction не распарсился")
            return
        }
        
        let expected = makeExpectedTransaction()
        
        XCTAssertEqual(transaction.id, expected.id)
        XCTAssertEqual(transaction.accountId, expected.accountId)
        XCTAssertEqual(transaction.categoryId, expected.categoryId)
        XCTAssertEqual(transaction.amount, expected.amount)
        XCTAssertEqual(transaction.comment, expected.comment)
        XCTAssertEqual(transaction.transactionDate, expected.transactionDate)
        XCTAssertEqual(transaction.createdAt, expected.createdAt)
        XCTAssertEqual(transaction.updatedAt, expected.updatedAt)
    }
    
    func testParse_MissingField() {
        var jsonObject = validTransactionJSON()
        jsonObject.removeValue(forKey: "accountId")
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNil(transaction, "nil, так как нет обязательного поля")
    }
    
    func testParse_InvalidAmount() {
        var jsonObject = validTransactionJSON()
        jsonObject["amount"] = "some string"
            
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как amount не парсится")
    }
    
    func testParse_EmptyStringAmount() {
        var jsonObject = validTransactionJSON()
        jsonObject["amount"] = ""
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNil(transaction)
    }
    
    func testParse_InvalidTransactionDate() {
        var jsonObject = validTransactionJSON()
        jsonObject["transactionDate"] = "202506-06T19:12:05Z"
            
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как transactionDate не парсится")
    }
    
    func testParse_InvalidCreatedAt() {
        var jsonObject = validTransactionJSON()
        jsonObject["createdAt"] = "2025-06--06T19:12:05Z"
            
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как createdAt не парсится")
    }
    
    func testParse_InvalidUpdatedAt() {
        var jsonObject = validTransactionJSON()
        jsonObject["updatedAt"] = "some string"
            
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как updatedAt не парсится")
    }
    
    func testParse_CommentIsNull() {
        var json = validTransactionJSON()
        json["comment"] = nil

        let transaction = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction?.comment)
    }
    
    func testParse_ExtraFields() {
        var jsonObject = validTransactionJSON()
        jsonObject["someKey"] = "someString"
        
        guard let transaction = Transaction.parse(jsonObject: jsonObject) else {
            XCTFail("Transaction не распарсился")
            return
        }
        
        let expected = makeExpectedTransaction()
        
        XCTAssertEqual(transaction.id, expected.id)
        XCTAssertEqual(transaction.accountId, expected.accountId)
        XCTAssertEqual(transaction.categoryId, expected.categoryId)
        XCTAssertEqual(transaction.amount, expected.amount)
        XCTAssertEqual(transaction.comment, expected.comment)
        XCTAssertEqual(transaction.transactionDate, expected.transactionDate)
        XCTAssertEqual(transaction.createdAt, expected.createdAt)
        XCTAssertEqual(transaction.updatedAt, expected.updatedAt)
    }
    
    private func validTransactionJSON() -> [String: Any] {
        return [
            "id": 1,
            "accountId": 2,
            "categoryId": 3,
            "amount": "123.45",
            "transactionDate": "2025-06-06T19:12:05Z",
            "comment": "Пример",
            "createdAt": "2025-06-06T19:12:05Z",
            "updatedAt": "2025-06-06T19:12:05Z"
        ]
    }
    
    private func makeExpectedTransaction() -> Transaction {
        let formatter = ISO8601DateFormatter()
        return Transaction(
            id: 1,
            accountId: 2,
            categoryId: 3,
            amount: Decimal(string: "123.45")!,
            transactionDate: formatter.date(from: "2025-06-06T19:12:05Z")!,
            comment: "Пример",
            createdAt: formatter.date(from: "2025-06-06T19:12:05Z")!,
            updatedAt: formatter.date(from: "2025-06-06T19:12:05Z")!
        )
    }
}
