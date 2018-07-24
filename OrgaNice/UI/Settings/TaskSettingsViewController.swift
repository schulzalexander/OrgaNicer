//
//  TaskSettingsViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 23.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskSettingsTableViewController: UITableViewController {

	//MARK: Properties
	var task: Task!
	
	//MARK: Outlets
	@IBOutlet weak var taskHeaderTextField: UITextField!
	@IBOutlet weak var frequencyPicker: UISegmentedControl!
	@IBOutlet weak var deadlineDatePicker: UIDatePicker!
	@IBOutlet weak var deadlineEnabledButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        self.taskHeaderTextField.text = task.title
		self.taskHeaderTextField.delegate = self
		
		self.updateDeadlineState()
    }
	
	@IBAction func didPickFrequency(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			deadlineDatePicker.datePickerMode = .dateAndTime
			if task.deadline != nil {
				deadlineDatePicker.date = task.deadline!
			}
		case 1:
			deadlineDatePicker.datePickerMode = .time
		case 2:
			deadlineDatePicker.datePickerMode = .date
		default:
			return
		}
	}
	
	@IBAction func didPickDeadline(_ sender: UIDatePicker) {
		task.deadline = sender.date
		TaskArchive.saveTask(task: task)
		updateTaskTable()
	}
	
	@IBAction func switchDeadlineEnabled(_ sender: UIButton) {
		if task.deadline != nil {
			task.deadline = nil
		} else {
			task.deadline = Date()
		}
		TaskArchive.saveTask(task: task)
		self.updateDeadlineState()
	}
	
	private func updateTaskTable() {
		guard let viewController = self.popoverPresentationController?.delegate as? TaskTableViewController else {
			return
		}
		viewController.updateTaskOrdering()
		viewController.tableView.reloadData()
	}
	
	private func updateDeadlineState() {
		if task.deadline != nil {
			deadlineDatePicker.isEnabled = true
			deadlineDatePicker.date = task.deadline ?? Date()
			deadlineEnabledButton.setTitle(NSLocalizedString("None", comment: ""), for: .normal)
		} else {
			deadlineDatePicker.isEnabled = false
			deadlineEnabledButton.setTitle(NSLocalizedString("Set", comment: ""), for: .normal)
		}
		deadlineEnabledButton.sizeToFit()
		updateTaskTable()
	}
}

extension TaskSettingsTableViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if textField.text != nil && textField.text?.count == 0 {
			textField.text = task.title
		} else {
			task.title = textField.text!
			TaskArchive.saveTask(task: task)
			updateTaskTable()
		}
		return true
	}
}

