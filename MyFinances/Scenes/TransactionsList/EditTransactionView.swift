//
//  EditTransactionView.swift
//  MyFinances
//
//  Created by Артём on 10.06.2025.
//

import SwiftUI

struct EditTransactionView: View {
    @StateObject var viewModel: EditTransactionViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showCalendar   = false
    @State private var showTimePicker = false
    @FocusState private var isAmountFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                title
                form
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView("Сохранение...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.2)
                    Text("Пожалуйста, подождите")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                .padding(20)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.showAlert) {
            Button("Ок", role: .cancel) { }
        }
        .sheet(isPresented: $viewModel.showCategoryPicker) { categorySheet }
        .sheet(isPresented: $showCalendar)        { calendarSheet }
        .sheet(isPresented: $showTimePicker)     { timeSheet    }
        .onChange(of: viewModel.saveCompleted) { _, newValue in
            if newValue { dismiss() }
        }
    }
}

private extension EditTransactionView {
    var header: some View {
        HStack {
            Button("Отмена") { dismiss() }
                .foregroundColor(.accentColor)
            Spacer()
            Button(viewModel.isEditing ? "Сохранить" : "Создать") {
                Task { await viewModel.save() }
            }
            .foregroundColor(.accentColor)
            .disabled(!viewModel.isValid)
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    var title: some View {
        Text(viewModel.direction == .income ? "Мои Доходы" : "Мои Расходы")
            .font(.system(size: 28, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom, 8)
    }
    
    var form: some View {
        List {
            categoryRow
            amountRow
            dateRow
            timeRow
            commentRow
            if viewModel.canDelete { deleteSection }
        }
        .listStyle(.insetGrouped)
        .environment(\.defaultMinListRowHeight, 48)
    }
    
    var categoryRow: some View {
        Button { viewModel.showCategoryPicker = true } label: {
            HStack {
                Text("Статья")
                    .foregroundColor(.gray)
                Spacer()
                Text(viewModel.selectedCategory?.name ?? "Выберите статью")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
    
    var amountRow: some View {
        HStack {
            Text("Сумма")
            Spacer()
            TextField("0", text: $viewModel.amount)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .focused($isAmountFocused)
                .onChange(of: viewModel.amount) { _, new in
                    viewModel.sanitizeAmountInput(new)
                }
                .frame(maxWidth: 120, alignment: .trailing)
        }
    }
    
    var dateRow: some View {
        DatePicker(
            "Дата",
            selection: $viewModel.selectedDate,
            in: ...Date(),
            displayedComponents: .date
        )
    }
    
    var timeRow: some View {
        DatePicker(
            "Время",
            selection: $viewModel.selectedDate,
            displayedComponents: .hourAndMinute
        )
    }
    
    var commentRow: some View {
        TextField(viewModel.commentPlaceholder, text: $viewModel.comment)
    }
    
    var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                Task {
                    await viewModel.delete()
                    if viewModel.deleteCompleted {
                        dismiss()
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.deleteButtonTitle)
                        .font(.system(size: 17))
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Color(.systemBackground))
        .listRowSeparator(.hidden)
    }
    
    var categorySheet: some View {
        NavigationView {
            List(viewModel.categories, id: \.id) { category in
                Button {
                    viewModel.selectedCategory = category
                    viewModel.showCategoryPicker = false
                } label: {
                    CategoryView(category: category)
                }
            }
            .navigationTitle("Выберите статью")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { viewModel.showCategoryPicker = false }
                }
            }
        }
    }
    
    var calendarSheet: some View {
        VStack {
            HStack {
                Spacer()
                Button("Готово") { showCalendar = false }.padding()
            }
            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding()
            Spacer()
        }
    }
    
    var timeSheet: some View {
        VStack {
            HStack {
                Spacer()
                Button("Готово") { showTimePicker = false }.padding()
            }
            DatePicker(
                "",
                selection: $viewModel.selectedDate,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()
            Spacer()
        }
    }
}
