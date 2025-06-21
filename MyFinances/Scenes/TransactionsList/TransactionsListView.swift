//
//  TransactionsListView.swift
//  MyFinances
//
//  Created by Артём on 19.06.2025.
//

import SwiftUI

// MARK: - Экраны доходов и расходов. Задаются параметрически
struct TransactionsListView: View {
    @StateObject var viewModel: TransactionsListViewModel
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    sort
                    amount
                    transactionsList
                }
                .navigationTitle(viewModel.navigationTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        historyButton
                    }
                }
                .onAppear {
                    Task { await viewModel.loadTransactions() }
                }
                
                plusButton
            }
        }
    }
    private var sort: some View {
        Section {
            Picker("Сортировка", selection: $viewModel.sortOption) {
                ForEach(TransactionsListViewModel.SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(.init())
        }
    }
    
    private var amount: some View {
        Section {
            AmountCellView(viewModel: AmountCellViewModel(transactions: viewModel.transactions))
                .listRowInsets(EdgeInsets())
        }
    }
    
    private var transactionsList: some View {
        Section(header: Text(TransactionsListConstants.headerTransactionsList)) {
            ForEach(viewModel.transactions, id: \.id) { transaction in
                if viewModel.direction == .income {
                    TransactionsListIncomeCellView(transaction: transaction)
                        .listRowInsets(EdgeInsets())
                } else {
                    TransactionsListOutcomeCellView(transaction: transaction)
                        .listRowInsets(EdgeInsets())
                }
                
            }
        }
    }
    
    private var historyButton: some View {
        Button {
            viewModel.isPresentingHistory = true
        } label: {
            Image(TransactionsListConstants.historyImageName)
        }
    }
    
    private var plusButton: some View {
        Button(action: {
            // TODO: Экран добавления (плюсик)
        }) { plus }
            .padding(.bottom, TransactionsListConstants.plusButtonBottom)
            .padding(.trailing, TransactionsListConstants.plusButtonTrailing)
    }
    
    private var plus: some View {
        Image(systemName: TransactionsListConstants.plusImageName)
            .foregroundColor(.white)
            .padding()
            .background(.accent)
            .clipShape(Circle())
    }
}

#Preview {
    TransactionsListView(viewModel: TransactionsListViewModel(direction: .income))
}
