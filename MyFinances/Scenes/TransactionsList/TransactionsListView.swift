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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                list
                plusButton
            }
            .navigationTitle(viewModel.navigationTitle)
            
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    historyButton
                }
            })
            
            .task { await viewModel.loadTransactions() }
        }
        
        .sheet(isPresented: $showCreateSheet, onDismiss: {
            Task { await viewModel.loadTransactions() }
        }) {
            EditTransactionView(
                viewModel: EditTransactionViewModel(
                    transaction: nil,
                    direction: viewModel.direction
                )
            )
        }
        
        .sheet(item: $editingTransaction, onDismiss: {
            Task { await viewModel.loadTransactions() }
        }) { trx in
            EditTransactionView(
                viewModel: EditTransactionViewModel(
                    transaction: trx,
                    direction: viewModel.direction
                )
            )
        }
        .task { await viewModel.loadTransactions() }
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
            AmountCellView(viewModel: AmountCellViewModel(transactions: viewModel.transactions))
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
            destination: HistoryView(viewModel: HistoryViewModel(direction: viewModel.direction))
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
        .padding(.bottom, TransactionsListConstants.plusButtonBottom)
        .padding(.trailing, TransactionsListConstants.plusButtonTrailing)
    }
}
