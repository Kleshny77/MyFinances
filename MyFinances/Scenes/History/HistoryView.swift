//
//  HistoryView.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

// HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: HistoryViewModel

    var body: some View {
        List {
            PeriodSectionView(
                start: $viewModel.period.start,
                end: $viewModel.period.end
            )
            TotalSectionView(formattedTotal: viewModel.formattedTotal)
            OperationsSectionView(transactions: viewModel.transactions)
        }
        .navigationTitle("Моя история")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PeriodSectionView: View {
    @Binding var start: Date
    @Binding var end: Date
    
    var body: some View {
        Section {
            DatePicker("Начало", selection: $start, displayedComponents: .date)
            DatePicker("Конец", selection: $end, displayedComponents: .date)
        }
    }
}

struct TotalSectionView: View {
    let formattedTotal: String

    var body: some View {
        Section {
            HStack {
                Text("Сумма")
                Spacer()
                Text(formattedTotal)
            }
        }
    }
}

struct OperationsSectionView: View {
    let transactions: [Transaction]

    var body: some View {
        Section(header: Text("Операции")) {
            if transactions.isEmpty {
                Text("Нет операций за выбранный период")
            } else {
                ForEach(transactions, id: \.id) { tx in
                    if tx.category.isIncome {
                        TransactionsListIncomeCellView(transaction: tx)
                    } else {
                        TransactionsListOutcomeCellView(transaction: tx)
                    }
                }
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(viewModel: HistoryViewModel(direction: .outcome))
    }
}
