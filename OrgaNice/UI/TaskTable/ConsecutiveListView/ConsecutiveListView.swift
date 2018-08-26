//
//  ConsecutiveListView.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class ConsecutiveListView: TaskTableViewCellContent, UITextFieldDelegate {
	
	static let lineHeight: CGFloat = 25
	static let linePaddingVertical: CGFloat = 10
	static let linePaddingHorizontal: CGFloat = 10
	static let toolButtonDimension: CGFloat = 30 // for add and remove button
	
	var parentTask: TaskConsecutiveList!
	var lines: [ConsecutiveListViewLine]!
	
	init(task: TaskConsecutiveList, frame: CGRect) {
		super.init(frame: frame)
		
		self.parentTask = task
		self.lines = [ConsecutiveListViewLine]()
		self.layoutConsecutiveTaskList(subtasks: task.subTasks)
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
			}
		} else {
			parentTask.subTasks?.remove(at: textField.tag)
			TaskArchive.saveTask(task: parentTask)
			tableview.reloadRows(at: [index], with: .automatic)
		}
		
		textField.resignFirstResponder()
		return true
	}
	
	private func layoutConsecutiveTaskList(subtasks: [String]?) {
		var currY = CheckListView.linePaddingVertical
		
		// for each task, add one line consisting of arrowIndicator textField
		// subtasks are represented by the normal Task class
		for i in 0..<(subtasks?.count ?? 0) {
			guard let task = TaskManager.shared.getTask(id: subtasks![i]) else {
				continue
			}
			let frame = CGRect(x: ConsecutiveListView.linePaddingHorizontal,
							   y: currY,
							   width: self.frame.width - 2 * ConsecutiveListView.linePaddingHorizontal,
							   height: CheckListView.lineHeight)
			let newLine = ConsecutiveListViewLine(task: task, frame: frame)
			newLine.titleTextField.delegate = self
			newLine.titleTextField.textColor = Utils.getTaskCellFontColor(priority: parentTask.cellHeight)
			newLine.titleTextField.tag = i
			self.addSubview(newLine)
			lines.append(newLine)
			currY += ConsecutiveListView.lineHeight + ConsecutiveListView.linePaddingVertical
		}
		if let count = subtasks?.count {
			setCurrentLine(index: count - 1)
		}
		
		let forwardButton = UIButton(frame: CGRect(x: self.frame.width - 10 - ConsecutiveListView.toolButtonDimension,
											   y: currY,
											   width: 0,
											   height: 0))
		forwardButton.setTitle(NSLocalizedString("Forward", comment: ""), for: .normal)
		forwardButton.sizeToFit()
		forwardButton.layer.cornerRadius = forwardButton.frame.height / 2
		forwardButton.addTarget(self, action: #selector(createFollowUpTask(_:)), for: .touchUpInside)
		let backButton = UIButton(frame: CGRect(x: forwardButton.frame.minX - 10 - ConsecutiveListView.toolButtonDimension,
												  y: currY,
												  width: 0,
												  height: 0))
		backButton.setTitle(NSLocalizedString("Back", comment: ""), for: .normal)
		backButton.layer.cornerRadius = forwardButton.frame.height / 2
		backButton.addTarget(self, action: #selector(rewindToLastTask(_:)), for: .touchUpInside)
		self.addSubview(forwardButton)
		self.addSubview(backButton)
		
		layer.borderColor = UIColor.white.cgColor
		layer.borderWidth = 1
		layer.cornerRadius = 5
		backgroundColor = UIColor.white.withAlphaComponent(0.2)
	}
	
	@objc private func createFollowUpTask(_ sender: UIButton) {
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
			let consecutiveList = newCell.cellExtension as? ConsecutiveListView else {
				fatalError("Checklist failed to retreive new checklist after tableview reload.")
		}
		let lastIndex = consecutiveList.lines.count - 1
		if lastIndex >= 0 {
			consecutiveList.lines[lastIndex].titleTextField.becomeFirstResponder()
			consecutiveList.setCurrentLine(index: lastIndex)
		}
	}
	
	@objc private func rewindToLastTask(_ sender: UIButton) {
		guard let tableView = self.superview?.superview as? UITableView,
			let cell = self.superview as? TaskTableViewCell,
			let index = tableView.indexPath(for: cell),
			let subtask = parentTask.subTasks?.last else {
				return
		}
		parentTask.removeSubtask(id: subtask)
		TaskManager.shared.deleteTask(id: subtask)
		tableView.reloadRows(at: [index], with: .automatic)
	}
	
	private func setCurrentLine(index: Int) {
		for i in 0..<lines.count {
			lines[i].setLineCurrent(isCurrent: i == index)
		}
	}
	
	static func getContentHeight(task: TaskConsecutiveList) -> CGFloat {
		let count = task.subTasks?.count
		return count != nil
			? CGFloat(count!) * ConsecutiveListView.lineHeight + CGFloat(count! + 2) * ConsecutiveListView.linePaddingVertical + ConsecutiveListView.toolButtonDimension
			: ConsecutiveListView.toolButtonDimension + 2 * ConsecutiveListView.linePaddingVertical
	}
	
}
