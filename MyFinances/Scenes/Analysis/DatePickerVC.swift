//
//  DatePickerVC.swift
//  MyFinances
//
//  Created by Assistant on 10.07.2025.
//

import UIKit

final class DatePickerVC: UIViewController {
    private let datePicker = UIDatePicker()
    private let titleLabel = UILabel()
    private let onDateSelected: (Date) -> Void
    
    init(title: String, initial: Date, onDateSelected: @escaping (Date) -> Void) {
        self.onDateSelected = onDateSelected
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        datePicker.date = initial
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, datePicker])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(doneTapped)
        )
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        onDateSelected(datePicker.date)
        dismiss(animated: true)
    }
} 