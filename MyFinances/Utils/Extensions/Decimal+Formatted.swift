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
}
