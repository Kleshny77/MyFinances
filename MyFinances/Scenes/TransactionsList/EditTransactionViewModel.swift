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
    
    private let transactionsService = TransactionsService()
    private let categoriesService   = CategoriesService()
    private let bankAccountsService = BankAccountsService()
    
    @Published var selectedCategory: Category?
    @Published var amount: String = ""
    @Published var selectedDate: Date = Date()
    @Published var comment: String = ""
    @Published var categories: [Category] = []
    @Published var showCategoryPicker = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var saveCompleted = false
    
    var onSave:   (() -> Void)?
    var onDelete: (() -> Void)?
    
    var isValid: Bool {
        guard selectedCategory != nil else { return false }
        let value = Decimal(string: amount.replacingOccurrences(of: Locale.current.decimalSeparator ?? ",", with: ".")) ?? 0
        return value > 0
    }
    
    var canDelete: Bool { isEditing }
    let commentPlaceholder = "Комментарий"
    var deleteButtonTitle: String { direction == .income ? "Удалить доход" : "Удалить расход" }
    
    init(transaction: Transaction?, direction: Direction) {
        self.originalTransaction = transaction
        self.isEditing = transaction != nil
        self.direction = direction
        
        if let trx = transaction {
            selectedCategory = trx.category
            amount = trx.amount.description.replacingOccurrences(of: ".", with: ",")
            selectedDate = trx.transactionDate
            comment = trx.comment ?? ""
        }
        
        Task { await loadCategories() }
    }
    
    func loadCategories() async {
        categories = (try? await categoriesService.fetchCategories(direction: direction)) ?? []
    }
    
    func save() async {
        guard isValid else { return showAlert("Заполните поля корректно") }
        
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
            
            let trx = Transaction(
                id: originalTransaction?.id ?? Int(Date().timeIntervalSince1970),
                account: account,
                category: selectedCategory!,
                amount: amountValue,
                transactionDate: selectedDate,
                comment: comment,
                createdAt: originalTransaction?.createdAt ?? Date(),
                updatedAt: Date()
            )
            
            if isEditing {
                try await transactionsService.updateTransaction(transaction: trx)
            } else {
                try await transactionsService.createTransaction(transaction: trx)
            }
            
            saveCompleted = true
            onSave?()
        } catch {
            showAlert("Ошибка: \(error.localizedDescription)")
        }
    }
    
    func delete() async {
        guard let id = originalTransaction?.id else { return }
        do {
            try await transactionsService.deleteTransaction(id: id)
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
