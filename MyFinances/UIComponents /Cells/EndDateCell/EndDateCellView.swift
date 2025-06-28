//
//  EndDateCellView.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Ячейка для отображения стартовой даты фильтрации
struct EndDateCellView: View {
    @ObservedObject var viewModel: EndDateCellViewModel
    
    var body: some View {
        HStack() {
            title
            
            Spacer()
            
            endDatePicker
        }
        .padding(.horizontal, CellsConstants.HStackHorizontal)
    }
    
    private var title: some View {
        Text("Конец")
            .font(.system(size: CellsConstants.fontSize))
    }
    
    private var endDatePicker: some View {
        DatePicker("", selection: $viewModel.endDate, displayedComponents: .date)
            .labelsHidden()
            .background(Color(red: 212/255.0, green: 250/255.0, blue: 230/255.0).cornerRadius(8))
            .accentColor(.supporting)

    }
}

#Preview {
    NavigationView {
        List {
            EndDateCellView(
                viewModel: EndDateCellViewModel(
                    endDate: Date(),
                    onChange: { _ in }
                )
            )
            .listRowInsets(EdgeInsets())
        }
    }
}

