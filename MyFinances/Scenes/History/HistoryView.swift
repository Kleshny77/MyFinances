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
    var currency: String = "RUB"
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showAnalysis = false
    @State private var editingTransaction: Transaction? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка истории...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        datePicker
                        transactionsList
                    }
                    .refreshable {
                        await loadTransactionsWithErrorHandling()
                    }
                }
            }
            .navigationTitle("История")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAnalysis = true }) {
                        Image(systemName: "document")
                    }
                }
            }
            .sheet(isPresented: $showAnalysis) {
                AnalysisView(
                    start: viewModel.startDate,
                    end: viewModel.endDate,
                    accountId: viewModel.accountId,
                    direction: viewModel.direction ?? .outcome
                )
            }
            .sheet(item: $editingTransaction, onDismiss: {
                Task { try? await viewModel.loadTransactions() }
            }) { trx in
                EditTransactionView(
                    viewModel: EditTransactionViewModel(
                        transaction: trx,
                        direction: viewModel.direction ?? .outcome,
                        accountId: viewModel.accountId,
                        transactionsService: TransactionsService.create(),
                        categoriesService: CategoriesService.create(),
                        bankAccountsService: BankAccountsService.create()
                    )
                )
            }
        }
        .task {
            await loadTransactionsWithErrorHandling()
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
            errorMessage = "Ошибка загрузки истории: \(error.localizedDescription)"
            showErrorAlert = true
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
            
            AmountCellView(viewModel: AmountCellViewModel(transactions: viewModel.transactions, currency: currency))
                .listRowInsets(EdgeInsets())
        }
    }
    
    private var transactionsList: some View {
        Section(header: Text(TransactionsListConstants.headerTransactionsList)) {
            ForEach(viewModel.transactions, id: \.id) { transaction in
                Group {
                    if viewModel.direction == .income {
                        TransactionsListIncomeCellView(transaction: transaction)
                    } else {
                        TransactionsListOutcomeCellView(transaction: transaction)
                    }
                }
                .listRowInsets(EdgeInsets())
                .contentShape(Rectangle())
                .onTapGesture { editingTransaction = transaction }
            }
        }
    }
}

