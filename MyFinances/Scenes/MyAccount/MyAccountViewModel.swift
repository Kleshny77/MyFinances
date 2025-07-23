//
//  MyAccountViewModel.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

@MainActor
final class MyAccountViewModel: ObservableObject {
    private let accountService: BankAccountsService
    
    @Published var account: BankAccount? = nil
    @Published var isLoading = false
    @Published var isEditingMode = false
    @Published var tempBalance: String = ""
    @Published var tempCurrency: String = ""
    @Published var showCurrencyPicker = false
    @Published var isBalanceHidden = false
    
    var totalAmount: String {
        if let account = account {
            return "\(account.balance)"
        } else {
            return "0"
        }
    }
    
    var currency: String {
        if let account = account {
            return "\(account.currencySymbol)"
        } else {
            return "?"
        }
    }
    
    init(accountService: BankAccountsService) {
        self.accountService = accountService
        // Убрана автозагрузка аккаунта из конструктора
    }
    
    func loadAccount() async throws {
        isLoading = true
        defer { isLoading = false }
        
        let acc = try await accountService.fetchAccount()
        account = acc
    }
    
    func startEditing() {
        guard let account = account else { return }
        isEditingMode = true
        tempBalance = String(describing: account.balance)
        tempCurrency = account.currency
    }
    
    func cancelEditing() {
        isEditingMode = false
        tempBalance = ""
        tempCurrency = ""
    }
    
    func updateTempBalance(_ value: String) {
        tempBalance = value
    }
    
    func updateTempCurrency(_ value: String) {
        tempCurrency = value
    }
    
    func saveChanges() async throws {
        guard let account = account else { return }
        isLoading = true
        defer { isLoading = false }
        
        let request = AccountUpdateRequest(
            name: account.name,
            balance: tempBalance,
            currency: tempCurrency
        )
        let updated = try await accountService.updateAccount(id: account.id, request: request)
        self.account = updated
        isEditingMode = false
    }
    
    @MainActor
    func refresh() async {
        do {
            try await loadAccount()
        } catch {
            // Ошибка при обновлении - пользователь увидит это в UI
        }
    }
    
    func toggleBalanceHidden() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isBalanceHidden.toggle()
        }
    }
    
    var availableCurrencies: [Currency] { Currency.allCases }
    
    var selectedCurrency: Currency? {
        Currency(rawValue: tempCurrency)
    }
    
    var formattedTempBalance: String {
        tempBalance
    }
    
    func isCurrencySelected(_ currency: Currency) -> Bool {
        tempCurrency == currency.rawValue
    }
    
    func selectCurrency(_ currency: Currency) {
        if tempCurrency != currency.rawValue {
            updateTempCurrency(currency.rawValue)
        }
    }
    
    var formattedBalance: String {
        totalAmount
    }
    
    var balanceCurrencySymbol: String {
        if let account = account {
            return account.currencySymbol
        } else {
            return "?"
        }
    }
}
