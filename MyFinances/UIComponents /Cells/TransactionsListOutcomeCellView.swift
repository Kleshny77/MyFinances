//
//  TransactionsListOutcomeCellView.swift
//  MyFinances
//
//  Created by Артём on 21.06.2025.
//

import Foundation
import SwiftUI

// MARK: - Ячейка для списка расходов
struct TransactionsListOutcomeCellView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: CellsConstants.HStackSpacing) {
            emoji
            name
            
            Spacer()
            
            amount
            currency
            arrow
        }
    }
    
    private var emoji: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: CellsConstants.circleSize, height: CellsConstants.circleSize)
            Text(String(transaction.category.emoji))
                .font(.system(size: CellsConstants.emojiFontSize))
        }
        .padding(.horizontal, CellsConstants.emojiHorizontal)
    }
    
    private var name: some View {
        VStack(alignment: .leading) {
            Text(transaction.category.name)
                .font(.system(size: CellsConstants.fontSize))
            
            if let comment = transaction.comment, !comment.isEmpty {
                Text(comment)
                    .foregroundStyle(Color(hex: CellsConstants.commentFontColor))
                    .font(.system(size: CellsConstants.commentFontSize))
            }
        }
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
            TransactionsListOutcomeCellView(transaction: PreviewMocks.sampleTransaction)
                .listRowInsets(EdgeInsets())
        }
        
    }
}

