//
//  TabBar.swift
//  MyFinances
//
//  Created by Артём on 06.06.2025.
//

import SwiftUI

// MARK: - Таб бар, отвечающий за переключение между экранами
struct TabBar: View {
    var body: some View {
        TabView {
            TransactionsListView(viewModel: TransactionsListViewModel(direction: .outcome))
                .tabItem {
                    Image(TabBarConstants.tabOnePath)
                    Text(TabBarConstants.tabOneName)
                }
            TransactionsListView(viewModel: TransactionsListViewModel(direction: .income))
                .tabItem {
                    Image(TabBarConstants.tabTwoPath)
                    Text(TabBarConstants.tabTwoName)
                }
            MyAccountView()
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

// MARK: - Мок для оставшихся экранов
struct MockView: View {
    var body: some View {
        Text("Some view")
    }
}

#Preview {
    TabBar()
}
