//
//  MyFinancesApp.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import SwiftUI

// MARK: - Вход в приложение
@main
struct MyFinancesApp: App {
    var body: some Scene {
        WindowGroup {
            AccountTabContainer()
        }
    }
}
