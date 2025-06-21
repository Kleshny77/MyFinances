//
//  TransactionsListIncomeCellView.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Ячейка для списка доходов
struct TransactionsListIncomeCellView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: CellsConstants.HStackSpacing) {
            name
            
            Spacer()
            
            amount
            currency
            arrow
        }
    }
    
    private var name: some View {
        Text(transaction.category.name)
            .font(.system(size: CellsConstants.fontSize))
            .padding(.leading, CellsConstants.nameLeading)
    }
    
    private var amount: some View {
        Text(String(describing: transaction.amount.formattedSmart))
    }
    
    private var currency: some View {
        Text(transaction.account.currencySymbol)
            .padding(.trailing, CellsConstants.currencyTrailing)
    }
    
    private var arrow: some View {
        Image(systemName: CellsConstants.arrowImageName)
            .foregroundStyle(.gray)
            .padding(.trailing, CellsConstants.arrowTrailing)
    }
}

#Preview {
    NavigationView {
        List {
            TransactionsListIncomeCellView(transaction: PreviewMocks.sampleTransaction)
                .listRowInsets(EdgeInsets())
        }
        
    }
}
