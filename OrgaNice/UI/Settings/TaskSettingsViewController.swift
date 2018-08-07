//
//  TaskSettingsViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 23.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskSettingsTableViewController: UITableViewController {

	static let DEADLINE_COLLAPSED_CELL_HEIGHT: CGFloat = 50
	static let DEADLINE_EXPANDED_CELL_HEIGHT: CGFloat = 194
	static let REMINDER_COLLAPSED_CELL_HEIGHT: CGFloat = 50
	static let REMINDER_EXPANDED_CELL_HEIGHT: CGFloat = 173
	
	//MARK: Properties
	var task: Task!
	var isDeadlineCellCollapsed: Bool = true
	var isReminderCellCollapsed: Bool = true
	
	//MARK: Outlets
	@IBOutlet weak var taskHeaderTextField: UITextField!
	@IBOutlet weak var frequencyPicker: UISegmentedControl!
	@IBOutlet weak var deadlineDatePicker: UIDatePicker!
	@IBOutlet weak var deadlineEnabledButton: UIButton!
	@IBOutlet weak var weekdayPicker: UIPickerView!
	@IBOutlet weak var deleteButton: UIButton!
	@IBOutlet weak var deadlineDropdownArrow: UILabel!
	@IBOutlet weak var deadlineRemindButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
        self.taskHeaderTextField.text = task.title
		self.taskHeaderTextField.sizeToFit()
		self.taskHeaderTextField.delegate = self
		
		self.weekdayPicker.dataSource = self
		self.weekdayPicker.delegate = self
		
		self.tableView.estimatedRowHeight = 0 // Without this, tableviews content size will be off
		self.tableView.sizeToFit()
		self.updatePopoverSize()
		
		self.setupDeleteButton()
		
		self.updateDeadlineState()
		self.updateDeadlineRemindButtonTitle()
    }
	
	@IBAction func didPickFrequency(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			deadlineDatePicker.datePickerMode = .dateAndTime
			if task.deadline != nil {
				task.deadline!.frequency = Deadline.Frequency.unique
				deadlineDatePicker.date = task.deadline!.date
			}
			hideWeekdayPicker()
		case 1:
			deadlineDatePicker.datePickerMode = .time
			if task.deadline != nil {
				task.deadline!.frequency = Deadline.Frequency.daily
				//TODO
			}
			hideWeekdayPicker()
		case 2:
			deadlineDatePicker.datePickerMode = .time
			if task.deadline != nil {
				task.deadline!.frequency = Deadline.Frequency.weekly
				//TODO
			}
			showWeekdayPicker()
		default:
			return
		}
		updateTaskTable()
	}
	
	@IBAction func didPressDeadlineRemindButton(_ sender: Any) {
		if task.hasAlarmSet(for: task.deadline!.id) {
			task.removeAlarm(alarmID: task.deadline!.id)
			if !task.hasAlarms() {
				self.isReminderCellCollapsed = true
				tableView.reloadData()
			}
		} else {
			task.addAlarm(alarm: Alarm(deadline: task.deadline!, sound: false))
			if self.isReminderCellCollapsed {
				self.isReminderCellCollapsed = false
				tableView.reloadData()
			}
		}
		updateDeadlineRemindButtonTitle()
	}
	
	func showWeekdayPicker() {
		weekdayPicker.isHidden = false
		weekdayPicker.frame.size.width = self.view.frame.width / 2 - 16
		weekdayPicker.center.x = self.view.frame.width / 4 + 8
		deadlineDatePicker.frame.size.width = self.view.frame.width / 2 - 16
		deadlineDatePicker.center.x = self.view.frame.width / 4 * 3 - 8
	}
	
	func hideWeekdayPicker() {
		weekdayPicker.isHidden = true
		deadlineDatePicker.frame.size.width = self.view.frame.width - 32
		deadlineDatePicker.center.x = self.view.frame.width / 2
	}
	
	@IBAction func startEditingTitle(_ sender: UIButton) {
		self.taskHeaderTextField.becomeFirstResponder()
	}
	
	@IBAction func didPickDeadline(_ sender: UIDatePicker) {
		task.deadline!.date = sender.date
		TaskArchive.saveTask(task: task)
		updateTaskTable()
	}
	
	@IBAction func switchDeadlineEnabled(_ sender: UIButton) {
		if task.deadline != nil {
			task.deadline = nil
			self.isDeadlineCellCollapsed = true
			self.tableView.reloadData()
		} else {
			task.deadline = Deadline(date: Date(), frequency: .unique)
			self.isDeadlineCellCollapsed = false
			self.tableView.reloadData()
		}
		self.rotateDeadlineArrow()
		TaskArchive.saveTask(task: task)
		self.updateDeadlineState()
		self.updatePopoverSize()
		self.updateDeadlineRemindButtonTitle()
	}
	
	@IBAction func deleteTask(_ sender: UIButton) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let delete = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
			TaskCategoryManager.shared.deleteTask(id: self.task.id)
			TaskManager.shared.deleteTask(id: self.task.id)
			self.dismiss(animated: true, completion: nil)
			
			guard let taskTable = self.popoverPresentationController?.delegate as? TaskTableViewController else {
				return
			}
			taskTable.tableView.reloadData()
		})
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(delete)
		alertController.addAction(cancel)
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 2 {
			return self.isDeadlineCellCollapsed
				? TaskSettingsTableViewController.DEADLINE_COLLAPSED_CELL_HEIGHT
				: TaskSettingsTableViewController.DEADLINE_EXPANDED_CELL_HEIGHT
		}
		if indexPath.row == 3 {
			return self.isReminderCellCollapsed
				? TaskSettingsTableViewController.REMINDER_COLLAPSED_CELL_HEIGHT
				: TaskSettingsTableViewController.REMINDER_EXPANDED_CELL_HEIGHT
		}
		return super.tableView(tableView, heightForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		super.tableView(tableView, heightForRowAt: indexPath)
		if indexPath.row == 2 && task.deadline != nil {
			self.isDeadlineCellCollapsed = !self.isDeadlineCellCollapsed
			self.rotateDeadlineArrow()
			tableView.reloadData()
			updatePopoverSize()
			return
		}
		if indexPath.row == 3 {
			self.isReminderCellCollapsed = !self.isReminderCellCollapsed
			tableView.reloadData()
			updatePopoverSize()
			return
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = super.tableView(tableView, cellForRowAt: indexPath)
		cell.selectionStyle = .none
		return cell
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
			deadlineDatePicker.date = task.deadline?.date ?? Date()
			deadlineEnabledButton.setTitle(NSLocalizedString("None", comment: ""), for: .normal)
			if frequencyPicker.selectedSegmentIndex == 2 {
				weekdayPicker.isUserInteractionEnabled = true
			}
		} else {
			deadlineDatePicker.isEnabled = false
			weekdayPicker.isUserInteractionEnabled = false
			deadlineEnabledButton.setTitle(NSLocalizedString("Set", comment: ""), for: .normal)
		}
		deadlineEnabledButton.sizeToFit()
		updateTaskTable()
	}
	
	private func setupDeleteButton() {
		deleteButton.backgroundColor = UIColor.red
		deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
		deleteButton.clipsToBounds = true
	}
	
	private func rotateDeadlineArrow() {
		let angle: CGFloat = self.isDeadlineCellCollapsed ? 0 : 180
		UIView.animate(withDuration: 0.35) {
			self.deadlineDropdownArrow.transform = CGAffineTransform.init(rotationAngle: angle / 360 * 2 * CGFloat.pi)
		}
	}
	
	private func updatePopoverSize() {
		self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: tableView.contentSize.height)
	}
	
	private func updateDeadlineRemindButtonTitle() {
		guard task.deadline != nil else {
			return
		}
		if task.hasAlarmSet(for: task.deadline!.id) {
			deadlineRemindButton.setTitle(NSLocalizedString("DontRemindMeButtonTitle", comment: ""), for: .normal)
		} else {
			deadlineRemindButton.setTitle(NSLocalizedString("RemindMeButtonTitle", comment: ""), for: .normal)
		}
		deadlineRemindButton.sizeToFit()
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

extension TaskSettingsTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 7
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch(row) {
		case 0:
			return NSLocalizedString("Monday", comment: "")
		case 1:
			return NSLocalizedString("Tuesday", comment: "")
		case 2:
			return NSLocalizedString("Wednesday", comment: "")
		case 3:
			return NSLocalizedString("Thursday", comment: "")
		case 4:
			return NSLocalizedString("Friday", comment: "")
		case 5:
			return NSLocalizedString("Saturday", comment: "")
		case 6:
			return NSLocalizedString("Sunday", comment: "")
		default:
			return ""
		}
	}
	
}

