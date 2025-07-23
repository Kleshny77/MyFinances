//
//  TransactionsListView.swift
//  MyFinances
//
//  Created by Артём on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @StateObject var viewModel: TransactionsListViewModel
    @State private var editingTransaction: Transaction?
    @State private var showCreateSheet = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    var onTransactionChanged: (() -> Void)? = nil
    var currency: String = "RUB"
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    VStack {
                        ProgressView("Загрузка транзакций...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2)
                        Text("Пожалуйста, подождите")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    VStack(spacing: 0) {
                        list
                        Spacer()
                    }
                }
                
                if !viewModel.isLoading {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            plusButton
                                .padding(.bottom, TransactionsListConstants.plusButtonBottom)
                                .padding(.trailing, TransactionsListConstants.plusButtonTrailing)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.isLoading {
                        historyButton
                    }
                }
            }
            
            .task { 
                await loadTransactionsWithErrorHandling()
            }
        }
        
        .sheet(isPresented: $showCreateSheet, onDismiss: {
            Task { 
                await loadTransactionsWithErrorHandling()
            }
            onTransactionChanged?()
        }) {
            EditTransactionView(
                viewModel: createEditTransactionViewModel(transaction: nil)
            )
        }
        
        .sheet(item: $editingTransaction, onDismiss: {
            Task { 
                await loadTransactionsWithErrorHandling()
            }
            onTransactionChanged?()
        }) { trx in
            EditTransactionView(
                viewModel: createEditTransactionViewModel(transaction: trx)
            )
        }
        
        .alert("Ошибка", isPresented: $showErrorAlert) {
            Button("Ок", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func loadTransactionsWithErrorHandling() async {
        do {
            try await viewModel.loadTransactions()
        } catch {
            errorMessage = "Ошибка загрузки транзакций: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
    
    private func createEditTransactionViewModel(transaction: Transaction?) -> EditTransactionViewModel {
        let viewModel = EditTransactionViewModel(
            transaction: transaction,
            direction: self.viewModel.direction,
            accountId: self.viewModel.accountId,
            transactionsService: TransactionsService.create(),
            categoriesService: CategoriesService.create(),
            bankAccountsService: BankAccountsService.create()
        )
        viewModel.onSave = {
            Task { 
                await self.loadTransactionsWithErrorHandling()
            }
            self.onTransactionChanged?()
        }
        viewModel.onDelete = {
            Task { 
                await self.loadTransactionsWithErrorHandling()
            }
            self.onTransactionChanged?()
        }
        return viewModel
    }
}

// MARK: – UI-helpers
private extension TransactionsListView {
    
    var list: some View {
        List {
            sortPicker
            amountSection
            transactionsSection
        }
    }
    
    var sortPicker: some View {
        Picker("Сортировка", selection: $viewModel.sortOption) {
            ForEach(TransactionsListViewModel.SortOption.allCases) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .listRowInsets(.init())
    }
    
    var amountSection: some View {
        Section {
            AmountCellView(viewModel: AmountCellViewModel(transactions: viewModel.transactions, currency: currency))
                .listRowInsets(EdgeInsets())
        }
    }
    
    var transactionsSection: some View {
        Section(header: Text(TransactionsListConstants.headerTransactionsList)) {
            ForEach(viewModel.transactions, id: \.id) { trx in
                transactionCell(for: trx)
                    .contentShape(Rectangle())
                    .onTapGesture { editingTransaction = trx }
            }
        }
    }
    
    func transactionCell(for trx: Transaction) -> some View {
        Group {
            if viewModel.direction == .income {
                TransactionsListIncomeCellView(transaction: trx)
            } else {
                TransactionsListOutcomeCellView(transaction: trx)
            }
        }
        .listRowInsets(EdgeInsets())
    }
    
    var historyButton: some View {
        NavigationLink(
            destination: HistoryView(viewModel: HistoryViewModel(direction: viewModel.direction, accountId: viewModel.accountId), currency: currency)
        ) {
            Image(TransactionsListConstants.historyImageName)
        }
    }
    
    var plusButton: some View {
        Button { showCreateSheet = true } label: {
            Image(systemName: TransactionsListConstants.plusImageName)
                .foregroundColor(.white)
                .padding()
                .background(Color.accentColor)
                .clipShape(Circle())
        }
    }
}
