//
//  AmountCellView.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Ячейка для отображения суммы расходов/доходов на главных экранах
struct AmountCellView: View {
    let viewModel: AmountCellViewModel
    
    var body: some View {
        HStack(spacing: CellsConstants.HStackSpacing) {
            title
            
            Spacer()
            
            totalAmount
            currency
        }
        .padding(.horizontal, CellsConstants.HStackHorizontal)
    }
    
    private var title: some View {
        Text(CellsConstants.titleAmountCell)
            .font(.system(size: CellsConstants.fontSize))
    }
    
    private var totalAmount: some View {
        Text(String(describing: viewModel.totalAmount))
            .font(.system(size: CellsConstants.fontSize))
    }
    
    private var currency: some View {
        Text(viewModel.currencySymbol)
    }
}

#Preview {
    NavigationView {
        List {
            AmountCellView(viewModel: AmountCellViewModel(transactions: PreviewMocks.sampleTransactions))
                .listRowInsets(EdgeInsets())
        }
        
    }
}

