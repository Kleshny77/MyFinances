//
//  ContentView.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Расходы", systemImage: "arrowshape.down.fill") {
                TransactionsListView(direction: .outcome)
            }
            
            Tab("Доходы", systemImage: "arrowshape.up.fill") {
                TransactionsListView(direction: .income)
            }
            
            Tab("Счет", systemImage: "sportscourt") {
                someView()
            }
            
            Tab("Статья", systemImage: "chart.bar.yaxis") {
                someView()
            }
            
            Tab("Настройки", systemImage: "gearshape.fill") {
                someView()
            }
        }
    }
}

#Preview {
    ContentView()
}

struct someView: View {
    var body: some View {
        Text("1")
    }
}
