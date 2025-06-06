//
//  MyFinancesTests.swift
//  MyFinancesTests
//
//  Created by Артём on 06.06.2025.
//

import XCTest
@testable import MyFinances

final class TransactionParseTests: XCTestCase {
    var jsonObject: [String : Any] = [:]
    
    override func setUpWithError() throws {
        jsonObject = [
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
    
    func testParse_Normal() {
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
        jsonObject.removeValue(forKey: "accountId")
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNil(transaction, "nil, так как нет обязательного поля")
    }
    
    func testParse_InvalidAmount() {
        jsonObject["amount"] = "some string"
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как amount не парсится")
    }
    
    func testParse_EmptyStringAmount() {
        jsonObject["amount"] = ""
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNil(transaction)
    }
    
    func testParse_InvalidTransactionDate() {
        jsonObject["transactionDate"] = "202506-06T19:12:05Z"
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как transactionDate не парсится")
    }
    
    func testParse_InvalidCreatedAt() {
        jsonObject["createdAt"] = "2025-06--06T19:12:05Z"
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как createdAt не парсится")
    }
    
    func testParse_InvalidUpdatedAt() {
        jsonObject["updatedAt"] = "some string"
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNil(transaction, "nil, так как updatedAt не парсится")
    }
    
    func testParse_CommentIsNull() {
        jsonObject["comment"] = nil
        
        let transaction = Transaction.parse(jsonObject: jsonObject)
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction?.comment)
    }
    
    func testParse_ExtraFields() {
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

final class TransactionJsonObjectTests: XCTestCase {
    var transaction: Transaction!
    
    override func setUpWithError() throws {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: "2025-06-06T19:12:05Z")!
        
        transaction = Transaction(id: 1, accountId: 2, categoryId: 3, amount: Decimal(string: "123.45")!, transactionDate: date, comment: "Пример", createdAt: date, updatedAt: date)
    }
    
    func testJsonObject_Normal() {
        let jsonObject = transaction.jsonObject as! [String: Any]
        
        let expected = makeExpectedJsonObject()
        
        for (key, expectedValue) in expected {
            let actualValue = jsonObject[key]

            switch expectedValue {
            case let int as Int:
                XCTAssertEqual(actualValue as? Int, int)

            case let str as String:
                XCTAssertEqual(actualValue as? String, str)

            case _ as NSNull:
                XCTAssertTrue(actualValue is NSNull)

            default:
                XCTFail("Unexpected type for key: \(key)")
            }
        }
    }
    
    func testJsonObject_CommentIsNil() {
        transaction.comment = nil

        let json = transaction.jsonObject as! [String: Any]

        XCTAssertTrue(json["comment"] is NSNull, "comment должен быть NSNull, если был nil")
    }
    
    private func makeExpectedJsonObject() -> [String : Any] {
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
}
