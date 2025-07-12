import SwiftUI

struct AnalysisViewControllerRepresentable: UIViewControllerRepresentable {
    let startDate: Date
    let endDate: Date
    let service: TransactionsService
    let direction: Direction
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        return AnalysisViewController(startDate: startDate, endDate: endDate, service: service, direction: direction)
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {
    }
} 
