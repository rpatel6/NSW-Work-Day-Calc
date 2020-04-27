//
//  ViewController.swift
//  NSW Work Day Calc
//
//  Created by Raj Patel on 26/04/20.
//  Copyright © 2020 Raj Patel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func calculateWorkdays(_ sender: UIButton) {
        view.endEditing(true)
        let calculator = WorkDayCalculator()
        guard let start = startDate, let end = endDate else {
            resultLabel.text = "Please pick both dates!"
            return
        }
        if let result = calculator.calculateWorkDays(with: start, and: end) {
            resultLabel.text = "Work Days: \(String(result))"
        } else {
            resultLabel.text = "Error occured while calculating the days :("
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Work Day Calculator"
        setupView()
    }
    
    private func setupView() {
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.addTarget(self, action: #selector(startDateSelected(with:)), for: .valueChanged)
        startInputTextfield.inputView = startDatePicker
        startInputTextfield.inputAccessoryView = accessoryButton()
        let endDatePicker = UIDatePicker()
        endDatePicker.datePickerMode = .date
        endDatePicker.addTarget(self, action: #selector(endDateSelected(with:)), for: .valueChanged)
        endInputTextfield.inputView = endDatePicker
        endInputTextfield.inputAccessoryView = accessoryButton()
    }
    
    @objc func startDateSelected(with picker: UIDatePicker) {
        startInputTextfield.text = dateFormatter.string(from: picker.date)
        startDate = picker.date
    }
    
    @objc func endDateSelected(with picker: UIDatePicker) {
        endInputTextfield.text = dateFormatter.string(from: picker.date)
        endDate = picker.date
    }
    
    private func accessoryButton() -> UIView {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 45))
        accessoryView.backgroundColor = .systemGray
        accessoryView.alpha = 0.6
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        
        let doneButton = UIButton(type: .roundedRect)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.black, for: .normal)
        doneButton.addTarget(self, action: #selector(dismissDatePicker), for: .touchUpInside)
        doneButton.isEnabled = true
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        accessoryView.addSubview(doneButton)
        
        doneButton.centerYAnchor.constraint(equalTo: accessoryView.centerYAnchor).isActive = true
        doneButton.trailingAnchor.constraint(equalTo: accessoryView.trailingAnchor, constant: -16).isActive = true
        return accessoryView
    }
    
    @objc func dismissDatePicker() {
        view.endEditing(true)
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()
    private var startDate: Date?
    private var endDate: Date?
    @IBOutlet private weak var startInputTextfield: UITextField!
    @IBOutlet private weak var endInputTextfield: UITextField!
    @IBOutlet private weak var resultLabel: UILabel!
}

