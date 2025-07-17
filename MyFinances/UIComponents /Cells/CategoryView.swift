//
//  CategoryView.swift
//  MyFinances
//
//  Created by Артём on 03.07.2025.
//

import Foundation
import SwiftUI

// MARK: - Ячейка для списка категорий
struct CategoryView: View {
    let category: Category
    
    var body: some View {
        HStack() {
            emoji
            name
        }
    }
    
    private var emoji: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: CellsConstants.circleSize, height: CellsConstants.circleSize)
            Text(String(category.emoji))
                .font(.system(size: CellsConstants.emojiFontSize))
        }
        .padding(.horizontal, CellsConstants.emojiHorizontal)
    }
    
    private var name: some View {
        VStack(alignment: .leading) {
            Text(category.name)
                .font(.system(size: CellsConstants.fontSize))
        }
    }
}
