//
//  MyAccountView.swift
//  MyFinances
//
//  Created by Артём on 27.06.2025.
//

import Foundation
import SwiftUI

extension String {
    var currencySymbol: String {
        switch self {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return "?"
        }
    }
}

struct ShakeGestureModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(ShakeGestureView(onShake: action))
    }
}

extension View {
    public func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeGestureModifier(action: action))
    }
}

private struct ShakeGestureView: UIViewRepresentable {
    let onShake: () -> Void
    
    func makeUIView(context: Context) -> ShakeRespondingView {
        let view = ShakeRespondingView()
        view.onShake = onShake
        return view
    }
    
    func updateUIView(_ uiView: ShakeRespondingView, context: Context) {}
}

private class ShakeRespondingView: UIView {
    var onShake: () -> Void = {}
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake()
        }
        super.motionEnded(motion, with: event)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }
}

final class EmitterView: UIView {
    override static var layerClass: AnyClass { CAEmitterLayer.self }
    
    override var layer: CAEmitterLayer {
        guard let emitterLayer = super.layer as? CAEmitterLayer else {
            fatalError("Expected CAEmitterLayer but got \(type(of: super.layer))")
        }
        return emitterLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.emitterPosition = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        layer.emitterSize = bounds.size
    }
}

struct SpoilerView: UIViewRepresentable {
    var isOn: Bool
    
    func makeUIView(context: Context) -> EmitterView {
        let emitterView = EmitterView()
        
        let emitterCell = CAEmitterCell()
        emitterCell.contents = UIImage(named: "textSpeckle_Normal")?.cgImage
        emitterCell.color = UIColor.black.cgColor
        emitterCell.contentsScale = 1.8
        emitterCell.emissionRange = .pi * 2
        emitterCell.lifetime = 1
        emitterCell.scale = 0.5
        emitterCell.velocityRange = 20
        emitterCell.alphaRange = 1
        emitterCell.birthRate = 300
        
        emitterView.layer.emitterShape = .rectangle
        emitterView.layer.emitterCells = [emitterCell]
        
        return emitterView
    }
    
    func updateUIView(_ uiView: EmitterView, context: Context) {
        if isOn {
            uiView.layer.beginTime = CACurrentMediaTime()
        }
        uiView.layer.birthRate = isOn ? 1 : 0
    }
}

struct SpoilerModifier: ViewModifier {
    let isOn: Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            SpoilerView(isOn: isOn)
        }
    }
}

extension View {
    func spoiler(isOn: Binding<Bool>) -> some View {
        self
            .opacity(isOn.wrappedValue ? 0 : 1)
            .modifier(SpoilerModifier(isOn: isOn.wrappedValue))
            .animation(.easeInOut(duration: 0.3), value: isOn.wrappedValue)
    }
}

enum Currency: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    
    var id: String { rawValue }
    
    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }
    
    var displayTitle: String {
        switch self {
        case .rub: return "Российский рубль ₽"
        case .usd: return "Американский доллар $"
        case .eur: return "Евро €"
        }
    }
}

struct MyAccountView: View {
    @StateObject var viewModel: MyAccountViewModel
    @FocusState private var isBalanceFocused: Bool
    @State private var showingCurrencySheet = false
    
    var body: some View {
        NavigationView {
            List {
                balance
                currency
            }
            .refreshable {
                await viewModel.refresh()
            }
            .navigationTitle("Мой счет")
            .listSectionSpacing(16)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isEditingMode {
                        Button("Сохранить") {
                            Task { await viewModel.saveChanges() }
                        }
                        .tint(.supporting)
                    } else {
                        Button("Редактировать") {
                            viewModel.startEditing()
                        }
                        .tint(.supporting)
                    }
                }
            }
            .onTapGesture {
                isBalanceFocused = false
            }
            .sheet(isPresented: $viewModel.showCurrencyPicker) {
                currencyPicker
            }
        }
        .onDisappear {
            if viewModel.isEditingMode {
                viewModel.cancelEditing()
            }
        }
        .onShake {
            viewModel.toggleBalanceHidden()
        }
    }
    
    private var balance: some View {
        Section {
            HStack(spacing: CellsConstants.HStackSpacing) {
                Text("💰")
                Text("Баланс")
                    .padding(.leading, 10)
                Spacer()
                if viewModel.isEditingMode {
                    TextField("0", text: $viewModel.tempBalance)
                        .keyboardType(.decimalPad)
                        .focused($isBalanceFocused)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120, alignment: .trailing)
                        .textFieldStyle(.plain)
                        .font(.system(size: CellsConstants.fontSize)).opacity(0.6)
                        .onChange(of: viewModel.tempBalance) { _, newValue in
                            let allowed = "0123456789.,"
                            let filtered = newValue.filter { allowed.contains($0) }
                            let parts = filtered.replacingOccurrences(of: ",", with: ".").split(separator: ".")
                            let result = parts.prefix(2).joined(separator: ".")
                            if result != newValue {
                                viewModel.tempBalance = result
                            }
                        }
                } else {
                    HStack(spacing: 4) {
                        Text(String(describing: viewModel.totalAmount))
                            .font(.system(size: CellsConstants.fontSize))
                            .spoiler(isOn: .constant(viewModel.isBalanceHidden))
                        Text(viewModel.currency)
                            .font(.system(size: CellsConstants.fontSize))
                            .spoiler(isOn: .constant(viewModel.isBalanceHidden))
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.isEditingMode {
                    isBalanceFocused = true
                }
            }
        }
        .listRowBackground(viewModel.isEditingMode ? Color(.white) : Color.accentColor)
    }
    
    private var currency: some View {
        Section {
            Button {
                if viewModel.isEditingMode {
                    showingCurrencySheet = true
                }
            } label: {
                HStack(spacing: CellsConstants.HStackSpacing) {
                    Text("Валюта")
                    Spacer()
                    if viewModel.isEditingMode {
                        Text(viewModel.selectedCurrency?.symbol ?? "?")
                            .font(.system(size: CellsConstants.fontSize)).opacity(0.6)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    } else {
                        Text(viewModel.currency)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showingCurrencySheet) {
                VStack(spacing: 0) {
                    Text("Валюта")
                        .font(.headline)
                        .foregroundColor(.supporting)
                        .padding(.vertical, 20)
                    VStack(spacing: 0) {
                        ForEach(viewModel.availableCurrencies) { currency in
                            Button {
                                viewModel.selectCurrency(currency)
                                showingCurrencySheet = false
                            } label: {
                                Text(currency.displayTitle)
                                    .foregroundColor(.supporting)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .contentShape(Rectangle())
                            .overlay(
                                VStack {
                                    Divider().foregroundStyle(.supporting.opacity(0.25))
                                    Spacer()
                                    Divider().foregroundStyle(.supporting.opacity(0.25))
                                }
                            )
                        }
                    }
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                .presentationDetents([.fraction(0.3)])
                .modifier(ClearSheetBackground())
            }
        }
        .listRowBackground(viewModel.isEditingMode ? Color(.white) : Color.accentColor.opacity(0.2))
    }
    
    private var currencyPicker: some View {
        VStack(spacing: 0) {
            Text("Валюта")
                .font(.headline)
                .foregroundColor(.supporting)
                .padding(.vertical, 20)
            
            VStack(spacing: 0) {
                ForEach(Array(Currency.allCases.enumerated()), id: \.element.id) { _, currency in
                    Button {
                        if viewModel.tempCurrency != currency.id {
                            viewModel.updateTempCurrency(currency.id)
                        }
                        viewModel.showCurrencyPicker = false
                    } label: {
                        Text(currency.displayTitle)
                            .foregroundColor(.supporting)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .contentShape(Rectangle())
                    .overlay(
                        VStack {
                            Divider().foregroundStyle(.supporting.opacity(0.25))
                            Spacer()
                            Divider().foregroundStyle(.supporting.opacity(0.25))
                        }
                    )
                }
            }
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        .presentationDetents([.fraction(0.3)])
        
        .modifier(ClearSheetBackground())
    }
    
    private struct ClearSheetBackground: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(
                    Color.clear
                        .ignoresSafeArea()
                )
        }
    }
}
