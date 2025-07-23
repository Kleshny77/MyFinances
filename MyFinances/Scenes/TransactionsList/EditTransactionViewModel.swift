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
    @Published var amount: String = ""
    @Published var comment: String = ""
    @Published var selectedDate: Date = Date()
    @Published var selectedCategory: Category?
    @Published var isLoading = false
    @Published var saveCompleted = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    private var transactionsService: TransactionsService?
    private let bankAccountsService = BankAccountsService.create()
    private let categoriesService = CategoriesService.create()
    
    let originalTransaction: Transaction?
    let isEditing: Bool
    let direction: Direction
    let accountId: Int
    
    @Published var categories: [Category] = []
    @Published var showCategoryPicker = false
    @Published var deleteCompleted = false
    
    var onSave: (() -> Void)?
    var onDelete: (() -> Void)?
    
    var isValid: Bool {
        guard selectedCategory != nil else { return false }
        let value = Decimal(string: amount.replacingOccurrences(of: Locale.current.decimalSeparator ?? ",", with: ".")) ?? 0
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
            do {
                try await initializeService()
                await loadCategories()
            } catch {
                transactionsService = TransactionsService.create()
                await loadCategories()
            }
        }
    }
    
    private func initializeService() async throws {
        transactionsService = await TransactionsService.createWithLocalStorage()
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
                guard let fetchedAccount = try await bankAccountsService.fetchAccount() else {
                    showAlert("Не удалось получить аккаунт")
                    return
                }
                account = fetchedAccount
            }
            let amountValue = Decimal(
                string: amount.replacingOccurrences(of: Locale.current.decimalSeparator ?? ".", with: ".")
            ) ?? 0
            let amountString = String(format: "%.2f", NSDecimalNumber(decimal: amountValue).doubleValue)
            // Форматируем дату без миллисекунд
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime]
            let dateString = isoFormatter.string(from: selectedDate)
            let request = TransactionRequest(
                accountId: account.id,
                categoryId: selectedCategory!.id,
                amount: amountString,
                transactionDate: dateString,
                comment: comment.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            guard let transactionsService = transactionsService else {
                let fallbackService = TransactionsService.create()
                if isEditing, let id = originalTransaction?.id {
                    try await fallbackService.updateTransaction(id: id, request: request)
                } else {
                    try await fallbackService.createTransaction(request: request)
                }
                saveCompleted = true
                onSave?()
                return
            }
            
            if isEditing, let id = originalTransaction?.id {
                try await transactionsService.updateTransaction(id: id, request: request)
            } else {
                try await transactionsService.createTransaction(request: request)
            }
            saveCompleted = true
            onSave?()
        } catch {
            showAlert("Ошибка при сохранении: \(error.localizedDescription)")
        }
    }

    func delete() async {
        guard let id = originalTransaction?.id else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let transactionsService = transactionsService else {
                let fallbackService = TransactionsService.create()
                try await fallbackService.deleteTransaction(id: id)
                deleteCompleted = true
                onDelete?()
                return
            }
            
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
