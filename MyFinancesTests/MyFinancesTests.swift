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
    
    func testParse_Normal() throws {
        guard let transaction = try Transaction.parse(jsonObject: jsonObject) else {
            XCTFail("Transaction не распарсился")
            return
        }
        let expected = makeExpectedTransaction()
        
        XCTAssertEqual(transaction, expected)
    }
    
    func testParse_MissingField() throws {
        jsonObject.removeValue(forKey: "accountId")
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: jsonObject)) { error in
            guard let parseError = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError")
            }
            
            switch parseError {
            case .missingField(let field):
                XCTAssertEqual(field, "accountId")
            default:
                XCTFail("Ожидался .missingField, получено: \(parseError)")
            }
        }
    }
    
    func testParse_InvalidAmount() throws {
        jsonObject["amount"] = "some string"
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: jsonObject)) { error in
            guard let parseError = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError")
            }
            switch parseError {
            case .invalidDecimal(let field, let value):
                XCTAssertEqual(field, "amount")
                XCTAssertEqual(value, "some string")
            default:
                XCTFail("Ожидался .invalidDecimal, получено: \(parseError)")
            }
        }
    }
    
    func testParse_EmptyStringAmount() throws {
        jsonObject["amount"] = ""
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: jsonObject)) { error in
            guard let parseError = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError")
            }
            switch parseError {
            case .invalidDecimal(let field, let value):
                XCTAssertEqual(field, "amount")
                XCTAssertEqual(value, "")
            default:
                XCTFail("Ожидался .invalidDecimal, получено: \(parseError)")
            }
        }
    }
    
    func testParse_InvalidTransactionDate() throws {
        jsonObject["transactionDate"] = "202506-06T19:12:05Z"
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: jsonObject)) { error in
            guard let parseError = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError")
            }
            switch parseError {
            case .invalidDate(let field, let value):
                XCTAssertEqual(field, "transactionDate")
                XCTAssertEqual(value, "202506-06T19:12:05Z")
            default:
                XCTFail("Ожидался .invalidDate, получено: \(parseError)")
            }
        }
    }
    
    func testParse_InvalidCreatedAt() throws {
        jsonObject["createdAt"] = "2025-06--06T19:12:05Z"
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: jsonObject)) { error in
            guard let parseError = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError")
            }
            switch parseError {
            case .invalidDate(let field, let value):
                XCTAssertEqual(field, "createdAt")
                XCTAssertEqual(value, "2025-06--06T19:12:05Z")
            default:
                XCTFail("Ожидался .invalidDate, получено: \(parseError)")
            }
        }
    }
    
    func testParse_InvalidUpdatedAt() throws {
        jsonObject["updatedAt"] = "some string"
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: jsonObject)) { error in
            guard let parseError = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError")
            }
            switch parseError {
            case .invalidDate(let field, let value):
                XCTAssertEqual(field, "updatedAt")
                XCTAssertEqual(value, "some string")
            default:
                XCTFail("Ожидался .invalidDate, получено: \(parseError)")
            }
        }
    }
    
    func testParse_CommentIsNull() throws {
        jsonObject["comment"] = nil
        let transaction = try Transaction.parse(jsonObject: jsonObject)
        
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction?.comment)
    }
    
    func testParse_ExtraFields() throws {
        jsonObject["someKey"] = "someString"
        
        guard let transaction = try Transaction.parse(jsonObject: jsonObject) else {
            XCTFail("Transaction не распарсился")
            return
        }
        let expected = makeExpectedTransaction()
        
        XCTAssertEqual(transaction, expected)
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
        let jsonObject = transaction.jsonObject
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
        let json = transaction.jsonObject
        
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
