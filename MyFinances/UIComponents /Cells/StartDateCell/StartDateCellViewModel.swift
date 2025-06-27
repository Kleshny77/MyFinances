//
//  StartDateCellViewModel.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

final class StartDateCellViewModel: ObservableObject {
    @Published var startDate: Date {
        didSet { onChange(startDate) }
    }

    private let onChange: (Date) -> Void

    init(startDate: Date, onChange: @escaping (Date) -> Void) {
        self.startDate = startDate
        self.onChange = onChange
    }
}
