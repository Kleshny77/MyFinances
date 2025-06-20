//
//  TransactionsListView.swift
//  MyFinances
//
//  Created by Артём on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    @State var transactions: [Transaction] = []
    var transactionsService = TransactionsService()
    @State private var isPresentingAdd = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                List {
                    Section {
                        cellAmount(transactions: transactions)
                    }
                    Section(header: Text("Операции")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray)) {
                            ForEach(transactions, id: \.id) { transaction in
                                cellOutcome(transaction: transaction)
                            }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(direction == .income ? "Доходы сегодня" : "Расходы сегодня")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            print("Открыть историю")
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
                .onAppear {
                    loadTransactions()
                }

                // Кнопка +
                Button(action: {
                    isPresentingAdd = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.bottom, 24)
                .padding(.trailing, 24)
            }
            .sheet(isPresented: $isPresentingAdd) {
                // TODO: экран добавления
            }
        }
    }
    
    private func loadTransactions() {
        isLoading = true
        Task {
            do {
                guard let endOfToday = Date.endOfToday else { return }
                let all = try await transactionsService.fetchTransactions(from: Date.startOfToday, to: endOfToday)
                let filtered = all.filter { direction == .income ? $0.category.isIncome : !$0.category.isIncome }
                DispatchQueue.main.async {
                    self.transactions = filtered
                    self.isLoading = false
                }
            } catch {
                print("Ошибка загрузки транзакций: \(error)")
                self.isLoading = false
            }
        }
    }
    
    private func cellOutcome(transaction: Transaction) -> some View {
        HStack {
            Text(String(transaction.category.emoji))
                .font(.system(size: 14.5))
                .padding((22 - 14.5) / 2) // как расчитать паддинг по макету?
                .background(Color.accentColor.opacity(0.2))  /*как расчитать прозрачность по макету?*/
                .clipShape(Circle())
            Text(transaction.category.name)
                .font(.system(size: 17))
                .padding(.horizontal, 10)
            
            Spacer()
            
            Text(String(describing: transaction.amount))
            switch transaction.account.currency {
            case "RUB":
                Text("₽")
            case "USD":
                Text("$")
            case "EUR":
                Text("€")
            default:
                Text("?")
            }
            
            Image(systemName: "chevron.forward")
        }
    }
    
    private func cellAmount(transactions: [Transaction]) -> some View  {
        HStack {
            Text("Всего")
                .font(.system(size: 17))
                .padding(.horizontal, 10)
            
            Spacer()
            
            let totalAmount = transactions.reduce(Decimal(0)) { $0 + $1.amount }
            
            Text(String(describing: totalAmount))
            if let first = transactions.first {
                switch first.account.currency {
                case "RUB":
                    Text("₽")
                case "USD":
                    Text("$")
                case "EUR":
                    Text("€")
                default:
                    Text("?")
                }
            }
        }
    }
}

extension Date {
    static var startOfToday: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    static var endOfToday: Date? {
        let calendar = Calendar.current
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return nil
        }
        return calendar.date(byAdding: .second, value: -1, to: startOfTomorrow)
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
