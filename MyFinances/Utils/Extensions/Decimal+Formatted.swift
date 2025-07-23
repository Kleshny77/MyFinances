//
//  Decimal+Formatted.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

// MARK: - Расширение для Decimal, чтобы преобразовывать числа по примеру: 12343,00 -> 12 343
extension Decimal {
    var formattedSmart: String {
        let formatter = NumberFormatterFactory.decimalSmart

        let doubleValue = (self as NSDecimalNumber).doubleValue
        let fractionalPart = abs(doubleValue.truncatingRemainder(dividingBy: 1))

        if fractionalPart == 0 {
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 0
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        }

        return formatter.string(from: self as NSNumber) ?? "\(self)"
    }
    func formattedPercent(of total: Decimal) -> String {
        guard total > 0 else { return "0%" }
        let percent = (self / total * 100).rounded(2)
        return "\(percent.formattedSmart)%"
    }
    func rounded(_ scale: Int) -> Decimal {
        var result = Decimal()
        var value = self
        NSDecimalRound(&result, &value, scale, .plain)
        return result
    }
}

enum TransactionSortOption { case date, amount }

extension Array where Element == Transaction {
    var totalAmount: Decimal { reduce(0) { $0 + $1.amount } }
    func filtered(by direction: Direction) -> [Transaction] {
        filter { direction == .income ? $0.category.isIncome : !$0.category.isIncome }
    }
    func sorted(by option: TransactionSortOption) -> [Transaction] {
        switch option {
        case .date: return sorted { $0.transactionDate > $1.transactionDate }
        case .amount: return sorted { $0.amount > $1.amount }
        }
    }
}
