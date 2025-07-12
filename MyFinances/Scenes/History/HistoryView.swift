//
//  HistoryView.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Экраны истории. Задаются параметрически
struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel
    @State private var showAnalysis = false
    
    var body: some View {
        List {
            sort
            datePicker
            transactionsList
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AnalysisView(
                        start: viewModel.startDate,
                        end:   viewModel.endDate
                    )
                    .navigationTitle("Анализ")
                    .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Image(systemName: "document")
                }
            }
        }
        .task { await viewModel.loadTransactions() }
    }
    
    private var sort: some View {
        Picker("Сортировка", selection: $viewModel.sortOption) {
            ForEach(TransactionsListViewModel.SortOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
            .pickerStyle(.segmented)
            .listRowInsets(.init())
        }
    }
    
    private var datePicker: some View {
        Section {
            StartDateCellView(viewModel: StartDateCellViewModel(startDate: viewModel.startDate) { newDate in
                viewModel.startDate = newDate
            })
            .listRowInsets(EdgeInsets())
            
            EndDateCellView(viewModel: EndDateCellViewModel(endDate: viewModel.endDate) { newDate in
                viewModel.endDate = newDate
            })
            .listRowInsets(EdgeInsets())
            
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
}

#Preview {
    TransactionsListView(viewModel: TransactionsListViewModel(direction: .income))
}
