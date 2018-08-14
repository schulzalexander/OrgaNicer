//
//  TaskSettingsViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 23.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit
import UserNotifications

class TaskSettingsTableViewController: UITableViewController {
	
	static let DEADLINE_COLLAPSED_CELL_HEIGHT: CGFloat = 50
	static let DEADLINE_EXPANDED_CELL_HEIGHT: CGFloat = 161
	static let REMINDER_COLLAPSED_CELL_HEIGHT: CGFloat = 50
	static let REMINDER_EXPANDED_DIFFERENT_CELL_HEIGHT: CGFloat = 292
	static let REMINDER_EXPANDED_SAME_CELL_HEIGHT: CGFloat = 135
	
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
	@IBOutlet weak var deadlineTodayButton: UIButton!
	@IBOutlet weak var deadlineDropdownArrow: UILabel!
	@IBOutlet weak var reminderDropdownArrow: UILabel!
	@IBOutlet weak var reminderEnabledButton: UIButton!
	@IBOutlet weak var reminderDifferentSwitch: UISwitch!
	@IBOutlet weak var reminderDatePicker: UIDatePicker!
	@IBOutlet weak var reminderFrequencyPicker: UISegmentedControl!
	@IBOutlet weak var reminderSoundSwitch: UISwitch!
	
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
		
		if task.deadline != nil {
			self.frequencyPicker.selectedSegmentIndex = task.deadline!.frequency.rawValue
			if task.deadline!.frequency == .weekly {
				showWeekdayPicker()
				deadlineDatePicker.datePickerMode = .time
				setWeekday()
			}
		} else {
			self.frequencyPicker.isEnabled = false
			self.deadlineDropdownArrow.textColor = UIColor.lightGray
		}
		if task.alarm == nil {
			self.reminderDropdownArrow.textColor = UIColor.lightGray
		}
		
		self.setupDeleteButton()
		self.updateDeadlineCellComponents()
		self.updateReminderCellComponents()
	}
	
	
	//MARK: Reminder Cell
	
	@IBAction func didChangeReminderDifferent(_ sender: UISwitch) {
		guard self.task.alarm != nil, self.task.deadline != nil else {
			return
		}
		if !sender.isOn {
			self.task.removeAlarm()
			self.task.addAlarm(alarm: Alarm(id: Utils.generateID(),
											date: task.deadline!.date,
											frequency: task.deadline!.frequency,
											sound: false))
			self.reminderDatePicker.date = self.task.alarm!.date
			self.reminderFrequencyPicker.selectedSegmentIndex = self.task.alarm!.frequency.rawValue
		} else {
			self.task.removeAlarm()
			self.task.addAlarm(alarm: Alarm(deadline: task.deadline!, sound: false))
			TaskArchive.saveTask(task: task)
		}
		self.tableView.reloadData()
	}
	
	@IBAction func didChangeReminderSoundEnabled(_ sender: UISwitch) {
		guard task.alarm != nil else {
			return
		}
		task.alarm!.sound = true
		task.resetAlarm()
		TaskArchive.saveTask(task: task)
	}
	
	@IBAction func switchReminderEnabled(_ sender: UIButton) {
		if task.alarm != nil {
			disableReminder()
			reminderStateSwitchCompletion()
		} else {
			guard task.deadline != nil else {
				return
			}
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
				guard error == nil else {
					print("Error while requesting user notification authorization: \(error!.localizedDescription)")
					return
				}
				if !success {
					print("No success requesting user notification authorization!")
					return
				} else {
					self.task.alarm = Alarm(deadline: self.task.deadline!, sound: false)
					self.isReminderCellCollapsed = false
					DispatchQueue.main.async {
						self.reminderStateSwitchCompletion()
					}
				}
			}
		}
	}
	
	private func reminderStateSwitchCompletion() {
		self.reminderDifferentSwitch.isOn = self.task.alarm != nil
		self.updateReminderCellComponents()
		TaskArchive.saveTask(task: task)
		self.tableView.reloadData()
	}
	
	//MARK: Deadline Cell
	
	@IBAction func didPickFrequency(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			deadlineDatePicker.datePickerMode = .dateAndTime
			task.deadline!.frequency = Deadline.Frequency.unique
			deadlineDatePicker.date = task.deadline!.date
			hideWeekdayPicker()
		case 1:
			deadlineDatePicker.datePickerMode = .time
			task.deadline!.frequency = Deadline.Frequency.daily
			hideWeekdayPicker()
		case 2:
			deadlineDatePicker.datePickerMode = .time
			task.deadline!.frequency = Deadline.Frequency.weekly
			showWeekdayPicker()
			setWeekday()
		default:
			return
		}
		if task.alarm != nil && !task.hasSeperateAlarm() {
			task.alarm!.frequency = task.deadline!.frequency
			task.resetAlarm()
		}
		updateTaskTable()
		TaskArchive.saveTask(task: task)
	}
	
	@IBAction func didPickDeadline(_ sender: UIDatePicker) {
		task.deadline!.date = sender.date
		if task.alarm != nil && !task.hasSeperateAlarm() {
			task.alarm!.date = sender.date
			task.resetAlarm()
		}
		TaskArchive.saveTask(task: task)
		updateTaskTable()
	}
	
	@IBAction func switchDeadlineEnabled(_ sender: UIButton) {
		if task.deadline != nil {
			task.deadline = nil
			self.isDeadlineCellCollapsed = true
			self.disableReminder()
			self.updateReminderCellComponents()
			self.frequencyPicker.isEnabled = false
			self.deadlineDropdownArrow.textColor = UIColor.lightGray
		} else {
			task.deadline = Deadline(date: Date(), frequency: .unique)
			self.isDeadlineCellCollapsed = false
			self.frequencyPicker.isEnabled = true
			self.deadlineDropdownArrow.textColor = UIColor.black
		}
		self.tableView.reloadData()
		TaskArchive.saveTask(task: task)
		self.updateDeadlineCellComponents()
		self.updatePopoverSize()
	}
	
	//MARK: General Settings Stuff
	
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
	
	@IBAction func startEditingTitle(_ sender: UIButton) {
		self.taskHeaderTextField.becomeFirstResponder()
	}
	
	//MARK: TableView Delegate
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 2 {
			return self.isDeadlineCellCollapsed
				? TaskSettingsTableViewController.DEADLINE_COLLAPSED_CELL_HEIGHT
				: TaskSettingsTableViewController.DEADLINE_EXPANDED_CELL_HEIGHT
		}
		if indexPath.row == 3 {
			return self.isReminderCellCollapsed
				? TaskSettingsTableViewController.REMINDER_COLLAPSED_CELL_HEIGHT
				: (task.hasSeperateAlarm() ? TaskSettingsTableViewController.REMINDER_EXPANDED_DIFFERENT_CELL_HEIGHT
					: TaskSettingsTableViewController.REMINDER_EXPANDED_SAME_CELL_HEIGHT)
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
		if indexPath.row == 3 && task.alarm != nil {
			self.isReminderCellCollapsed = !self.isReminderCellCollapsed
			self.rotateReminderArrow()
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
	
	//MARK: Private Methods
	
	private func showWeekdayPicker() {
		weekdayPicker.isHidden = false
		weekdayPicker.frame.size.width = self.view.frame.width / 2 - 16
		weekdayPicker.center.x = self.view.frame.width / 4 + 8
		deadlineDatePicker.frame.size.width = self.view.frame.width / 2 - 16
		deadlineDatePicker.center.x = self.view.frame.width / 4 * 3 - 8
	}
	
	private func hideWeekdayPicker() {
		weekdayPicker.isHidden = true
		deadlineDatePicker.frame.size.width = self.view.frame.width - 32
		deadlineDatePicker.center.x = self.view.frame.width / 2
	}
	
	private func updateTaskTable() {
		guard let viewController = self.popoverPresentationController?.delegate as? TaskTableViewController else {
			return
		}
		viewController.updateTaskOrdering()
		viewController.tableView.reloadData()
	}
	
	private func updateDeadlineCellComponents() {
		if task.deadline != nil {
			deadlineDropdownArrow.textColor = UIColor.black
			deadlineDatePicker.isEnabled = true
			deadlineDatePicker.date = task.deadline?.date ?? Date()
			deadlineEnabledButton.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
			if frequencyPicker.selectedSegmentIndex == 2 {
				weekdayPicker.isUserInteractionEnabled = true
			}
		} else {
			deadlineDropdownArrow.textColor = UIColor.lightGray
			deadlineDatePicker.isEnabled = false
			weekdayPicker.isUserInteractionEnabled = false
			deadlineEnabledButton.setTitle(NSLocalizedString("Set", comment: ""), for: .normal)
		}
		deadlineEnabledButton.sizeToFit()
		updateTaskTable()
		rotateDeadlineArrow()
	}
	
	private func updateReminderCellComponents() {
		if task.alarm != nil {
			reminderDropdownArrow.textColor = UIColor.black
			reminderEnabledButton.setTitle(NSLocalizedString("Delete", comment: ""), for: .normal)
			reminderDifferentSwitch.isOn = !task.hasSeperateAlarm()
			reminderSoundSwitch.isOn = task.alarm!.sound
		} else {
			reminderDropdownArrow.textColor = UIColor.lightGray
			reminderEnabledButton.setTitle(NSLocalizedString("Set", comment: ""), for: .normal)
		}
		reminderEnabledButton.sizeToFit()
		rotateReminderArrow()
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
	
	private func rotateReminderArrow() {
		let angle: CGFloat = self.isReminderCellCollapsed ? 0 : 180
		UIView.animate(withDuration: 0.35) {
			self.reminderDropdownArrow.transform = CGAffineTransform.init(rotationAngle: angle / 360 * 2 * CGFloat.pi)
		}
	}
	
	private func updatePopoverSize() {
		self.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: tableView.contentSize.height)
	}
	
	private func setWeekday() {
		guard self.task.deadline != nil else {
			return
		}
		let weekday = Calendar.current.component(.weekday, from: self.task.deadline!.date)
		self.weekdayPicker.selectRow(weekday - 1, inComponent: 0, animated: false)
		
	}
	
	private func disableReminder() {
		task.removeAlarm()
		isReminderCellCollapsed = true
		updateReminderCellComponents()
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
		return DateFormatter().weekdaySymbols[row]
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		guard task.deadline != nil else {
			return
		}
		var date = task.deadline!.date
		for _ in 0...7 {
			if Calendar.current.component(.weekday, from: date) - 1 == row {
				task.deadline!.date = date
				deadlineDatePicker.setDate(date, animated: false)
				updateTaskTable()
				break
			}
			date.addTimeInterval(3600 * 24)
		}
	}
	
}

