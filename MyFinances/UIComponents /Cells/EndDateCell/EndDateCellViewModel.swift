//
//  EndDateCellViewModel.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

final class EndDateCellViewModel: ObservableObject {
    @Published var endDate: Date {
        didSet { onChange(endDate) }
    }

    private let onChange: (Date) -> Void

    init(endDate: Date, onChange: @escaping (Date) -> Void) {
        self.endDate = endDate
        self.onChange = onChange
    }
}
