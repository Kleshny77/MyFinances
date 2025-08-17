//
//  PieChartTableCell.swift
//  MyFinances
//
//  Created by Артём on 24.07.2025.
//

import UIKit
import PieChart

final class PieChartTableCell: UITableViewCell {
    static let reuseIdentifier = "PieChartTableCell"
    private let chartView = PieChartView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 240)
        ])
    }
    
    func configure(with entities: [Entity]) {
        chartView.updateEntities(entities, animated: true)
        chartView.lineWidth = 24
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startShortAnimation()
        }
    }
    
    private func startShortAnimation() {
        chartView.layer.removeAllAnimations()
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 2.0
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.fromValue = 0.3
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.duration = 0.8
        fadeInAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        chartView.layer.add(rotationAnimation, forKey: "shortRotation")
        chartView.layer.add(fadeInAnimation, forKey: "fadeIn")
    }
} 
