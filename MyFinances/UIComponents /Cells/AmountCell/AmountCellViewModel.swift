//
//  AmountCellViewModel.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

struct AmountCellViewModel {
    let totalAmount: String
    let currencySymbol: String

    init(transactions: [Transaction], currency: String = "RUB") {
        let amount = transactions.totalAmount
        self.totalAmount = amount.formattedSmart

        // Определяем символ валюты
        let symbol: String
        switch currency {
        case "RUB": symbol = "₽"
        case "USD": symbol = "$"
        case "EUR": symbol = "€"
        default: symbol = "?"
        }
        self.currencySymbol = symbol
    }
}
