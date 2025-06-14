//
//  DateFormatterFactory.swift
//  MyFinances
//
//  Created by Артём on 14.06.2025.
//

import Foundation

// MARK: - Фабрика форматтеров дат
enum DateFormatterFactory {
    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()
    
    static func date(from isoString: String) -> Date? {
        return iso8601.date(from: isoString)
    }
}
