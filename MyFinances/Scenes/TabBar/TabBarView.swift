//
//  TabBar.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import SwiftUI

// MARK: - Таб бар, отвечающий за переключение между экранами
struct TabBar: View {
    @StateObject private var accountViewModel = MyAccountViewModel()
    @State private var isLoading = true
    
    init() {
        UITabBar.appearance().backgroundColor = .white
    }
    
    private func reloadAccount() async {
        await accountViewModel.refresh()
    }
    
    var body: some View {
        TabView {
            if let account = accountViewModel.account {
                TransactionsListView(
                    viewModel: TransactionsListViewModel(direction: .outcome, accountId: account.id),
                    onTransactionChanged: { Task { await reloadAccount() } },
                    currency: account.currency
                )
                .tabItem {
                    Image(TabBarConstants.tabOnePath)
                    Text(TabBarConstants.tabOneName)
                }
                TransactionsListView(
                    viewModel: TransactionsListViewModel(direction: .income, accountId: account.id),
                    onTransactionChanged: { Task { await reloadAccount() } },
                    currency: account.currency
                )
                .tabItem {
                    Image(TabBarConstants.tabTwoPath)
                    Text(TabBarConstants.tabTwoName)
                }
                MyAccountView(viewModel: accountViewModel)
                    .tabItem {
                        Image(TabBarConstants.tabThreePath)
                        Text(TabBarConstants.tabThreeName)
                    }
                СategoriesView(viewModel: СategoriesViewModel())
                    .tabItem {
                        Image(TabBarConstants.tabFourPath)
                        Text(TabBarConstants.tabFourName)
                    }
                MockView()
                    .tabItem {
                        Image(TabBarConstants.tabFivePath)
                        Text(TabBarConstants.tabFiveName)
                    }
            } else if isLoading {
                ProgressView("Загрузка аккаунта...")
            } else {
                Text("Не удалось загрузить аккаунт")
            }
        }
        .task {
            await reloadAccount()
            isLoading = false
        }
    }
}

// MARK: - Мок для оставшихся экранов
struct MockView: View {
    var body: some View {
        Text("Some view")
    }
}

#Preview {
    TabBar()
}
