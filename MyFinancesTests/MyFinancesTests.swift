//
//  MyFinancesTests.swift
//  MyFinancesTests
//
//  Created by Артём on 06.06.2025.
//

import XCTest
@testable import MyFinances

final class TransactionParseTests: XCTestCase {
    var json: [String : Any] = [:]
    let iso = DateFormatterFactory.iso8601
    
    override func setUpWithError() throws {
        json = [
            TransactionCases.id.rawValue: 1,
            TransactionCases.account.rawValue: [
                BankAccountCases.id.rawValue: 2,
                BankAccountCases.userId.rawValue: 1,
                BankAccountCases.name.rawValue: "Основной счёт",
                BankAccountCases.balance.rawValue: "0.00",
                BankAccountCases.currency.rawValue: "RUB",
                BankAccountCases.createdAt.rawValue: "2025-06-06T19:12:05Z",
                BankAccountCases.updatedAt.rawValue: "2025-06-06T19:12:05Z"
            ],
            TransactionCases.category.rawValue: [
                CategoryCases.id.rawValue: 3,
                CategoryCases.name.rawValue: "Продукты",
                CategoryCases.emoji.rawValue: "🍎",
                CategoryCases.isIncome.rawValue: false
            ],
            TransactionCases.amount.rawValue: "123.45",
            TransactionCases.transactionDate.rawValue: "2025-06-06T19:12:05Z",
            TransactionCases.comment.rawValue: "Пример",
            TransactionCases.createdAt.rawValue: "2025-06-06T19:12:05Z",
            TransactionCases.updatedAt.rawValue: "2025-06-06T19:12:05Z"
        ]
    }
    
    func testParse_Normal() throws {
        let transaction = try Transaction.parse(jsonObject: json)
        let expected = makeExpectedTransaction()
        
        XCTAssertEqual(transaction, expected)
    }
    
    func testParse_MissingField() throws {
        json.removeValue(forKey: TransactionCases.amount.rawValue)
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: json)) { error in
            guard case .missingField(let field) = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError.missingField")
            }
            
            XCTAssertEqual(field, TransactionCases.amount.rawValue)
        }
    }
    
    func testParse_InvalidAmount() throws {
        json[TransactionCases.amount.rawValue] = "some string"
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: json)) { error in
            guard case .invalidDecimal(let field, let value) = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError.invalidDecimal")
            }
            
            XCTAssertEqual(field, TransactionCases.amount.rawValue)
            XCTAssertEqual(value, "some string")
        }
    }
    
    func testParse_InvalidTransactionDate() throws {
        json[TransactionCases.transactionDate.rawValue] = "202506-06T19:12:05Z"
        
        XCTAssertThrowsError(try Transaction.parse(jsonObject: json)) { error in
            guard case .invalidDate(let field, _) = error as? ParseError else {
                return XCTFail("Ошибка должна быть типа ParseError.invalidDate")
            }
            
            XCTAssertEqual(field, TransactionCases.transactionDate.rawValue)
        }
    }
    
    func testParse_CommentIsNull() throws {
        json[TransactionCases.comment.rawValue] = nil
        let transaction = try Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction.comment)
    }
    
    func testParse_ExtraFields() throws {
        json["someKey"] = "someString"
        
        let transaction = try Transaction.parse(jsonObject: json)
        let expected = makeExpectedTransaction()
        
        XCTAssertEqual(transaction, expected)
    }
    
    private func makeExpectedTransaction() -> Transaction {
        let date = iso.date(from: "2025-06-06T19:12:05Z")!
        
        let account = BankAccount(
            id: 2, userId: 1, name: "Основной счёт",
            balance: 0, currency: "RUB",
            createdAt: date, updatedAt: date
        )
        
        let category = Category(
            id: 3, name: "Продукты", emoji: "🍎", isIncome: false
        )
        
        return Transaction(
            id: 1, account: account, category: category,
            amount: Decimal(string: "123.45")!,
            transactionDate: date,
            comment: "Пример",
            createdAt: date, updatedAt: date
        )
    }
}

// MARK: - Тестирование свойства jsonObject
final class TransactionJsonObjectTests: XCTestCase {
    var transaction: Transaction!
    let iso = DateFormatterFactory.iso8601
    
    override func setUpWithError() throws {
        let date = iso.date(from: "2025-06-06T19:12:05Z")!
        
        transaction = Transaction(
            id: 1,
            account: BankAccount(
                id: 2,
                userId: 1,
                name: "Основной счёт",
                balance: 0,
                currency: "RUB",
                createdAt: date,
                updatedAt: date
            ),
            category: Category(
                id: 3,
                name: "Продукты",
                emoji: "🍎",
                isIncome: false
            ),
            amount: Decimal(string: "123.45")!,
            transactionDate: date,
            comment: "Пример",
            createdAt: date,
            updatedAt: date
        )
    }
    
    func testJsonObject_Normal() {
        let jsonObject = transaction.jsonObject
        guard let account = jsonObject[TransactionCases.account.rawValue] as? [String: Any]
        else { return XCTFail("account отсутствует") }
        
        XCTAssertEqual(account[BankAccountCases.id.rawValue] as? Int, 2)
        XCTAssertEqual(account[BankAccountCases.name.rawValue] as? String, "Основной счёт")
        
        guard let category = jsonObject[TransactionCases.category.rawValue] as? [String: Any]
        else { return XCTFail("category отсутствует") }
        
        XCTAssertEqual(category[CategoryCases.id.rawValue] as? Int, 3)
        XCTAssertEqual(category[CategoryCases.name.rawValue] as? String, "Продукты")
        XCTAssertEqual(category[CategoryCases.emoji.rawValue] as? String, "🍎")
    }
    
    func testJsonObject_CommentIsNil() {
        transaction.comment = nil
        let json = transaction.jsonObject
        
        XCTAssertNil(json[TransactionCases.comment.rawValue])
    }
}
