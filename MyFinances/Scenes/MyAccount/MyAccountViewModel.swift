//
//  MyAccountViewModel.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI
import Charts

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
    @Published var transactions: [Transaction] = []
    
    @Published var selectedDataPoint: ChartDataPoint? = nil
    
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
    
    func isCurrencySelected(_ currency: Currency) -> Bool {
        tempCurrency == currency.rawValue
    }
    
    func selectCurrency(_ currency: Currency) {
        if tempCurrency != currency.rawValue {
            updateTempCurrency(currency.rawValue)
        }
    }
    
    var balanceCurrencySymbol: String {
        if let account = account {
            return account.currencySymbol
        } else {
            return "?"
        }
    }
    
    func loadTransactions(service: TransactionsService, accountId: Int) async {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate)!
        let formatter = DateFormatterFactory.yyyyMMdd
        do {
            let responses = try await service.fetchTransactions(
                accountId: accountId,
                startDate: formatter.string(from: startDate),
                endDate: formatter.string(from: endDate)
            )
            self.transactions = responses.map { Transaction.fromAPI($0) }
        } catch {
            self.transactions = []
        }
    }
}

class ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Decimal
    let type: BalanceChangeType
    enum BalanceChangeType: String {
        case income, expense
    }
    init(date: Date, amount: Decimal, type: BalanceChangeType) {
        self.date = date
        self.amount = amount
        self.type = type
    }
}

extension MyAccountViewModel {
    var chartData: [ChartDataPoint] {
        let endDate = Date()
        let calendar = Calendar.current
        var points: [ChartDataPoint] = []
        
        for offset in (0..<30).reversed() {
            let day = calendar.date(byAdding: .day, value: -offset, to: endDate)!
            let dayTransactions = transactions.filter { calendar.isDate($0.transactionDate, inSameDayAs: day) }
            
            let dayChange = dayTransactions.reduce(Decimal(0)) { $0 + ($1.category.isIncome ? $1.amount : -$1.amount) }
            
            if dayChange != 0 {
                let type: ChartDataPoint.BalanceChangeType = dayChange > 0 ? .income : .expense
                points.append(ChartDataPoint(date: day, amount: abs(dayChange), type: type))
            }
        }
        return points
    }
    
    var monthlyChartData: [ChartDataPoint] {
        let endDate = Date()
        let calendar = Calendar.current
        var points: [ChartDataPoint] = []
        
        for offset in (0..<24).reversed() {
            let month = calendar.date(byAdding: .month, value: -offset, to: endDate)!
            let monthStart = calendar.dateInterval(of: .month, for: month)!.start
            let monthEnd = calendar.dateInterval(of: .month, for: month)!.end
            
            let monthTransactions = transactions.filter { transaction in
                transaction.transactionDate >= monthStart && transaction.transactionDate < monthEnd
            }
            
            let monthChange = monthTransactions.reduce(Decimal(0)) { $0 + ($1.category.isIncome ? $1.amount : -$1.amount) }
            
            if monthChange != 0 {
                let type: ChartDataPoint.BalanceChangeType = monthChange > 0 ? .income : .expense
                points.append(ChartDataPoint(date: monthStart, amount: abs(monthChange), type: type))
            }
        }
        return points
    }
    
    func clearChartSelection() { selectedDataPoint = nil }
}
