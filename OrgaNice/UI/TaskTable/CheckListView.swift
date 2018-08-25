//
//  CheckListView.swift
//  OrgaNice
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
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		guard let cell = textField.superview?.superview?.superview as? TaskTableViewCell,
			let tableview = cell.superview as? UITableView,
			let index = tableview.indexPath(for: cell) else {
			fatalError("Failed to retreive checklist line after return on title textfield!")
		}
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
		
		textField.resignFirstResponder()
		return true
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
		/*layer.shadowOffset = CGSize(width: 0, height: 0)
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowRadius = 3
		layer.shadowOpacity = 1
		layer.cornerRadius = 10*/
		//layer.shadowPath = UIBezierPath(roundedRect: self.frame, cornerRadius: 10).cgPath
		
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
		guard let tableView = self.superview?.superview as? UITableView,
			let cell = self.superview as? TaskTableViewCell,
			let index = tableView.indexPath(for: cell) else {
			fatalError("Checklist failed to retreive containing tableview.")
		}
		tableView.reloadData()
		guard let newCell = tableView.cellForRow(at: index) as? TaskTableViewCell,
			let checklist = newCell.cellExtension as? CheckListView else {
			fatalError("Checklist failed to retreive new checklist after tableview reload.")
		}
		checklist.lines.last?.titleTextField.isEnabled = true
		checklist.lines.last?.titleTextField.becomeFirstResponder()
	}
	
	@objc private func removeSubTask(_ sender: UIButton) {
		guard markedLine != nil,
			let tableView = self.superview?.superview as? UITableView,
			let cell = self.superview as? TaskTableViewCell,
			let index = tableView.indexPath(for: cell) else {
			return
		}
		parentTask.removeSubtask(id: markedLine!.task.id)
		TaskManager.shared.deleteTask(id: markedLine!.task.id)
		tableView.reloadRows(at: [index], with: .automatic)
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

