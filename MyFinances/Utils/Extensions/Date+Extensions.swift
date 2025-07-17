import Foundation

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        let components = DateComponents(year: calendar.component(.year, from: self),
                                     month: calendar.component(.month, from: self) + 1,
                                     day: 0)
        return calendar.date(from: components) ?? self
    }
} 
