//
//  TabBar.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import SwiftUI

// MARK: - Таб бар, отвечающий за переключение между экранами
struct AccountTabContainer: View {
    @State private var accountViewModel: MyAccountViewModel? = nil
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let accountViewModel = accountViewModel, let _ = accountViewModel.account {
                TabBar(accountViewModel: accountViewModel)
            } else if isLoading {
                ProgressView("Загрузка аккаунта...")
            } else {
                Text("Не удалось загрузить аккаунт")
            }
        }
        .task {
            let service = await BankAccountsService.createWithLocalStorage()
            let vm = MyAccountViewModel(accountService: service)
            self.accountViewModel = vm
            await vm.refresh()
            isLoading = false
        }
    }
}

struct TabBar: View {
    @ObservedObject var accountViewModel: MyAccountViewModel
    
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
            }
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
    AccountTabContainer()
}
