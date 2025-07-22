//
//  AmountCellViewModel.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

struct AmountCellViewModel {
    let totalAmount: String
    let currencySymbol: String?

    init(transactions: [Transaction]) {
        let amount = transactions.reduce(Decimal(0)) { $0 + $1.amount }
        self.totalAmount = amount.formattedSmart

        self.currencySymbol = transactions.first?.account.currencySymbol
    }
}
