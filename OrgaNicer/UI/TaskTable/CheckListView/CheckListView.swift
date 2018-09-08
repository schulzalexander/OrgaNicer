//
//  CheckListView.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class CheckListView: TaskTableViewCellContent, UITextFieldDelegate, UIGestureRecognizerDelegate {
	
	static let lineHeight: CGFloat = 25
	static let linePaddingVertical: CGFloat = 10
	static let linePaddingHorizontal: CGFloat = 10
	static let toolButtonDimension: CGFloat = 30 // for add and remove button
	
	var parentTask: TaskCheckList!
	var lines: [CheckListViewLine]!
	var markedLine: CheckListViewLine? // Clicking the remove button will delete the currently marked line
	
	init(task: TaskCheckList, frame: CGRect) {
		super.init(frame: frame)
		self.parentTask = task
		self.lines = [CheckListViewLine]()
		
		layoutChecklist(subtasks: task.subTasks)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	//MARK: UITextFieldDelegate
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// Add overlay view on whole screen, so that user can also end editing by tapping outside the keyboard
		guard let line = textField.superview as? CheckListViewLine else {
			fatalError("Failed to retrieve checklist line from textfield delegate function!")
		}
		let saveTaskTapGestureRecognizer = UITapGestureRecognizer(target: line, action: #selector(CheckListViewLine.stopEditingSubtask(_:)))
		saveTaskTapGestureRecognizer.delegate = line
		let view = UIView(frame: UIScreen.main.bounds)
		view.addGestureRecognizer(saveTaskTapGestureRecognizer)
		window?.addSubview(view)
		window?.bringSubview(toFront: view)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		saveSubTask(textField)
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		window?.subviews.last?.removeFromSuperview()
	}
	
	@objc func saveSubTask(_ textField: UITextField) {
		guard let cell = textField.superview?.superview?.superview as? TaskTableViewCell,
			let tableview = cell.getTableView(),
			let index = tableview.indexPath(for: cell) else {
				fatalError("Failed to retreive checklist line after return on title textfield!")
		}
		
		// Save the new subtask if title is non empty, else delete line
		if textField.text != nil && textField.text!.count > 0 {
			if parentTask.subTasks != nil, let task = TaskManager.shared.getTask(id: parentTask.subTasks![textField.tag]) {
				task.title = textField.text ?? ""
				TaskArchive.saveTask(task: task)
				if markedLine == nil || markedLine!.task.id != task.id {
					// Title was initially edited, so disable the textField since this line is not marked
					textField.isEnabled = false
				}
			}
		} else {
			parentTask.subTasks?.remove(at: textField.tag)
			TaskArchive.saveTask(task: parentTask)
			tableview.reloadRows(at: [index], with: .automatic)
		}
	}
	
	private func layoutChecklist(subtasks: [String]?) {
		var currY = CheckListView.linePaddingVertical
		
		// for each task, add one line consisting of textField and checkbox
		// subtasks are represented by the normal Task class
		for i in 0..<(subtasks?.count ?? 0) {
			guard let task = TaskManager.shared.getTask(id: subtasks![i]) else {
				continue
			}
			let frame = CGRect(x: CheckListView.linePaddingHorizontal,
							   y: currY,
							   width: self.frame.width - 2 * CheckListView.linePaddingHorizontal,
							   height: CheckListView.lineHeight)
			let newLine = CheckListViewLine(task: task, frame: frame)
			newLine.titleTextField.delegate = self
			newLine.titleTextField.textColor = Utils.getTaskCellFontColor(priority: parentTask.cellHeight)
			newLine.titleTextField.tag = i
			newLine.checkButton.tag = i
			
			let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(markLine(_:)))
			gestureRecognizer.delegate = self
			newLine.addGestureRecognizer(gestureRecognizer)
			
			self.addSubview(newLine)
			lines.append(newLine)
			currY += CheckListView.lineHeight + CheckListView.linePaddingVertical
		}
		
		let addButton = UIButton(frame: CGRect(x: self.frame.width - 10 - CheckListView.toolButtonDimension,
											   y: currY,
											   width: CheckListView.toolButtonDimension,
											   height: CheckListView.toolButtonDimension))
		addButton.setTitle("+", for: .normal)
		addButton.setTitleColor(Utils.getTaskCellColor(priority: parentTask.cellHeight), for: .normal)
		addButton.layer.cornerRadius = addButton.frame.height / 2
		addButton.layer.backgroundColor = UIColor.white.cgColor
		addButton.addTarget(self, action: #selector(addSubTask), for: .touchUpInside)
		let removeButton = UIButton(frame: CGRect(x: addButton.frame.minX - 10 - CheckListView.toolButtonDimension,
												  y: currY,
												  width: CheckListView.toolButtonDimension,
												  height: CheckListView.toolButtonDimension))
		removeButton.setTitle("-", for: .normal)
		removeButton.setTitleColor(Utils.getTaskCellColor(priority: parentTask.cellHeight), for: .normal)
		removeButton.layer.cornerRadius = addButton.frame.height / 2
		removeButton.layer.backgroundColor = UIColor.white.cgColor
		removeButton.addTarget(self, action: #selector(removeSubTask), for: .touchUpInside)
		self.addSubview(addButton)
		self.addSubview(removeButton)
		
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 1
		layer.cornerRadius = 5
		backgroundColor = UIColor.white.withAlphaComponent(0.2)//Utils.getTaskCellColor(priority: parentTask.cellHeight)
	}
	
	@objc private func addSubTask(_ sender: UIButton) {
		let newTask = Task(title: "")
		TaskManager.shared.addTask(task: newTask)
		if parentTask.subTasks != nil {
			parentTask.subTasks!.append(newTask.id)
		} else {
			parentTask.subTasks = [newTask.id]
		}
		TaskArchive.saveTask(task: parentTask)
		guard let cell = self.superview as? TaskTableViewCell,
			let tableView = cell.getTableView(),
			let index = tableView.indexPath(for: cell) else {
			fatalError("Checklist failed to retreive containing tableview.")
		}
		tableView.reloadRows(at: [index], with: .automatic)
		guard let newCell = tableView.cellForRow(at: index) as? TaskTableViewCell,
			let checklist = newCell.cellExtension as? CheckListView else {
			fatalError("Checklist failed to retreive new checklist after tableview reload.")
		}
		checklist.lines.last?.titleTextField.isEnabled = true
		checklist.lines.last?.titleTextField.becomeFirstResponder()
	}
	
	@objc private func removeSubTask(_ sender: UIButton) {
		guard let cell = self.superview as? TaskTableViewCell,
			let tableView = cell.getTableView(),
			let index = tableView.indexPath(for: cell) else {
			return
		}
		if markedLine == nil {
			if (parentTask.subTasks?.count ?? 0) > 0 {
				// Remove button was pressed, but no selection
				guard let viewController = tableView.delegate as? TaskTableViewController else {
					fatalError("Error: Failed to retrieve tableview delegeate when trying to show alertController, reason: no selected checklistline during removal.")
				}
				let alertController = UIAlertController(title: nil, message: NSLocalizedString("CheckListViewAlertControllerMessage", comment: ""), preferredStyle: .alert)
				alertController.addAction(UIAlertAction(title: NSLocalizedString("GotIt", comment: ""), style: .cancel, handler: nil))
				viewController.present(alertController, animated: true, completion: nil)
				
			} else {
				// Remove button was pressed with no subtasks -> remove checklist
				downcastToMainTask()
			}
		} else {
			parentTask.removeSubtask(id: markedLine!.task.id)
			if parentTask.subTasks?.count == 0 {
				downcastToMainTask()
			} else {
				TaskArchive.saveTask(task: parentTask)
			}
			TaskManager.shared.deleteTask(id: markedLine!.task.id)
		}
		tableView.reloadRows(at: [index], with: .automatic)
	}
	
	private func downcastToMainTask() {
		let mainTask = MainTask(task: parentTask)
		TaskManager.shared.addTask(task: mainTask)
	}
	
	@objc private func markLine(_ sender: UITapGestureRecognizer) {
		guard let line = sender.view as? CheckListViewLine else {
			fatalError("Error: View attached to TapGestureRecognizer is not of type CheckListViewLine!")
		}
		
		UIView.animate(withDuration: 0.3) {
			line.backgroundColor = UIColor(red: 0.8078, green: 0.9412, blue: 1, alpha: 1.0)
		}
		UIView.animate(withDuration: 0.3) {
			self.markedLine?.backgroundColor = UIColor.clear
		}
		
		line.titleTextField.isEnabled = true
		self.markedLine?.titleTextField.isEnabled = false
		self.markedLine = line
	}
	
	
	static func getContentHeight(task: TaskCheckList) -> CGFloat {
		let count = task.subTasks?.count
		return count != nil
			? CGFloat(count!) * CheckListView.lineHeight + CGFloat(count! + 2) * CheckListView.linePaddingVertical + CheckListView.toolButtonDimension
			: CheckListView.toolButtonDimension + 2 * CheckListView.linePaddingVertical
	}
	
}

