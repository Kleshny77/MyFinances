//
//  AnalysisView.swift
//  MyFinances
//
//  Created by Assistant on 10.07.2025.
//

import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    let start: Date
    let end: Date
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController()
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
        // Обновление не требуется
    }
}
