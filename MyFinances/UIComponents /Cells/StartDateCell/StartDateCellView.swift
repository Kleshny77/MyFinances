//
//  StartDateCell.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Ячейка для отображения стартовой даты фильтрации
struct StartDateCellView: View {
    @ObservedObject var viewModel: StartDateCellViewModel
    
    var body: some View {
        HStack() {
            title
            
            Spacer()
            
            startDatePicker
        }
        .padding(.horizontal, CellsConstants.HStackHorizontal)
    }
    
    private var title: some View {
        Text("Начало")
            .font(.system(size: CellsConstants.fontSize))
    }
    
    private var startDatePicker: some View {
        DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
            .labelsHidden()
            .background(Color(red: 212/255.0, green: 250/255.0, blue: 230/255.0).cornerRadius(8))
            .accentColor(.supporting) 
    }
}

#Preview {
    NavigationView {
        List {
            StartDateCellView(
                viewModel: StartDateCellViewModel(
                    startDate: Date(),
                    onChange: { _ in }
                )
            )
            .listRowInsets(EdgeInsets())
        }
    }
}
