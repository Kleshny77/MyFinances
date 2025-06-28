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
    private let accountService = BankAccountsService()
    
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
    
    init() {
        Task {
            await loadAccount()
        }
    }
    
    func loadAccount() async {
        isLoading = true
        do {
            let acc = try await accountService.fetchAccount()
            account = acc
        } catch {
            print("Ошибка при загрузке аккаунта: \(error)")
        }
        isLoading = false
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
    
    func saveChanges() async {
        guard let account = account else { return }
        isLoading = true
        do {
            let newBalance = Decimal(string: tempBalance) ?? account.balance
            let updated = try await accountService.updateAccount(account: account, balance: newBalance, currency: tempCurrency)
            self.account = updated
            isEditingMode = false
        } catch {
            print("Ошибка при сохранении: \(error)")
        }
        isLoading = false
    }
    
    @MainActor
    func refresh() async {
        await loadAccount()
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
