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
                    Image(TabBarConstants.tabOneName)
                    Text(TabBarConstants.tabOneName)
                }
            TransactionsListView(viewModel: TransactionsListViewModel(direction: .income))
                .tabItem {
                    Image(TabBarConstants.tabTwoName)
                    Text(TabBarConstants.tabTwoName)
                }
            MockView()
                .tabItem {
                    Image(TabBarConstants.tabThreeName)
                    Text(TabBarConstants.tabThreeName)
                }
            MockView()
                .tabItem {
                    Image(TabBarConstants.tabFourName)
                    Text(TabBarConstants.tabFourName)
                }
            MockView()
                .tabItem {
                    Image(TabBarConstants.tabFiveName)
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
