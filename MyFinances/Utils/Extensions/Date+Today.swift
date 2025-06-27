//
//  Date+Today.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation

// MARK: - Расширение для Date, помогающее удобно обращаться к началу и концу текущего дня
extension Date {
    private static let calendar = Calendar.current
    
    static var startOfToday: Date {
        calendar.startOfDay(for: .now)
    }
    
    static var endOfToday: Date? {
        guard let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) else {
            return nil
        }
        return calendar.date(byAdding: .second, value: -1, to: startOfTomorrow)
    }
    
    static func startOfDay(for date: Date) -> Date {
        Calendar.current.startOfDay(for: date)
    }

    static func endOfDay(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfDay(for: date)) ?? date
        return calendar.date(byAdding: .second, value: -1, to: startOfTomorrow) ?? date
    }
}
