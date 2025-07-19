//
//  EditTransactionViewModel.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import Foundation
import SwiftUI

@MainActor
final class EditTransactionViewModel: ObservableObject {
    private let originalTransaction: Transaction?
    let isEditing: Bool
    let direction: Direction
    private let accountId: Int

    private let transactionsService = TransactionsService.create()
    private let categoriesService = CategoriesService.create()
    private let bankAccountsService = BankAccountsService.create()

    @Published var selectedCategory: Category?
    @Published var amount: String = ""
    @Published var selectedDate: Date = Date()
    @Published var comment: String = ""
    @Published var categories: [Category] = []
    @Published var showCategoryPicker = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var saveCompleted = false
    @Published var deleteCompleted = false
    @Published var isLoading = false

    var onSave:   (() -> Void)?
    var onDelete: (() -> Void)?

    var isValid: Bool {
        guard selectedCategory != nil else { return false }
        let value = Decimal(string: amount.replacingOccurrences(of: Locale.current.decimalSeparator ?? ",",
                                                                with: ".")) ?? 0
        return value > 0
    }

    var canDelete: Bool { isEditing }
    let commentPlaceholder = "Комментарий"
    var deleteButtonTitle: String { direction == .income ? "Удалить доход" : "Удалить расход" }

    init(transaction: Transaction?, direction: Direction, accountId: Int) {
        self.originalTransaction = transaction
        self.isEditing = transaction != nil
        self.direction = direction
        self.accountId = accountId

        if let trx = transaction {
            selectedCategory = trx.category
            amount = trx.amount.description.replacingOccurrences(of: ".", with: ",")
            selectedDate = trx.transactionDate
            comment = trx.comment ?? ""
        }

        Task { 
            await loadCategories()
        }
    }

    func loadCategories() async {
        do {
            let allCategories = try await categoriesService.fetchCategories()
            switch direction {
            case .income:
                categories = allCategories.filter { $0.isIncome }
            case .outcome:
                categories = allCategories.filter { !$0.isIncome }
            }
        } catch {
            categories = []
        }
    }

    func save() async {
        guard isValid else { return showAlert("Заполните поля корректно") }

        isLoading = true
        defer { isLoading = false }

        do {
            let account: BankAccount
            if let trx = originalTransaction {
                account = trx.account
            } else {
                account = try await bankAccountsService.fetchAccount()
            }

            let amountValue = Decimal(
                string: amount.replacingOccurrences(of: Locale.current.decimalSeparator ?? ",", with: ".")
            ) ?? 0
            let amountString = String(format: "%.2f", NSDecimalNumber(decimal: amountValue).doubleValue)

            let request = TransactionRequest(
                accountId: account.id,
                categoryId: selectedCategory!.id,
                amount: amountString,
                transactionDate: DateFormatterFactory.iso8601Full.string(from: selectedDate),
                comment: comment.isEmpty ? " " : comment
            )

            if isEditing, let id = originalTransaction?.id {
                try await transactionsService.updateTransaction(id: id, request: request)
            } else {
                try await transactionsService.createTransaction(request: request)
            }

            saveCompleted = true
            onSave?()
        
        } catch {
            if let networkError = error as? NetworkError {
                switch networkError {
                case .httpError(let code, _):
                    // HTTP ошибка - показываем пользователю
                    showAlert("Ошибка сервера: \(code)")
                case .decodingFailed(_):
                    // Если операция создания/обновления прошла, но ответ не смогли декодировать — не показываем alert, просто завершаем
                    saveCompleted = true
                    onSave?()
                case .encodingFailed(_):
                    showAlert("Ошибка кодирования данных")
                case .invalidResponse:
                    showAlert("Неверный ответ сервера")
                case .network(let err):
                    showAlert("Ошибка сети: \(err.localizedDescription)")
                }
            } else {
                showAlert("Ошибка: \(error.localizedDescription)")
            }
        }
    }

    func delete() async {
        guard let id = originalTransaction?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await transactionsService.deleteTransaction(id: id)
            deleteCompleted = true
            onDelete?()
        } catch {
            showAlert("Ошибка: \(error.localizedDescription)")
        }
    }

    func sanitizeAmountInput(_ input: String) {
        let sep = Locale.current.decimalSeparator ?? ","
        let allowed = Set("0123456789" + sep)
        var out = ""
        var hasSep = false
        for ch in input where allowed.contains(ch) {
            if ch == Character(sep) {
                if !hasSep { out.append(sep); hasSep = true }
            } else {
                out.append(ch)
            }
        }
        amount = out
    }

    private func showAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
