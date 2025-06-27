//
//  MyAccountView.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

struct MyAccountView: View {
    
    
    var body: some View {
        NavigationView {
            List {
                balance
            }
            .navigationTitle("Мой счет")
        }
    }
    
    private var balance: some View {
        Section {
            HStack {
                Text("💰")
                Text("Баланс")
            }
        }
    }
    
}
