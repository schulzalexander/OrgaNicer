//
//  CheckListView.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class CheckListView: TaskTableViewCellContent, UITextFieldDelegate {
	
	static let lineHeight: CGFloat = 20
	static let linePaddingVertical: CGFloat = 10
	static let linePaddingHorizontal: CGFloat = 10
	static let toolButtonDimension: CGFloat = 30 // for add and remove button
	
	var parentTask: TaskCheckList!
	var lines: [CheckListViewLine]!
	
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
			if let task = parentTask.subTasks?[textField.tag] {
				task.title = textField.text ?? ""
				TaskArchive.saveTask(task: parentTask)
			}
		} else {
			parentTask.subTasks?.remove(at: textField.tag)
			tableview.reloadRows(at: [index], with: .automatic)
		}
		
		textField.resignFirstResponder()
		return true
	}
	
	private func layoutChecklist(subtasks: [Task]?) {
		var currY = CheckListView.linePaddingVertical
		
		// for each task, add one line consisting of textField and checkbox
		// subtasks are represented by the normal Task class
		for i in 0..<(subtasks?.count ?? 0) {
			let frame = CGRect(x: CheckListView.linePaddingHorizontal,
							   y: currY,
							   width: self.frame.width - 2 * CheckListView.linePaddingHorizontal,
							   height: CheckListView.lineHeight)
			let newLine = CheckListViewLine(task: subtasks![i], frame: frame)
			newLine.titleTextField.delegate = self
			newLine.titleTextField.textColor = Utils.getTaskCellFontColor(priority: parentTask.cellHeight)
			newLine.titleTextField.tag = i
			newLine.checkButton.tag = i
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
		
	}
	
	@objc private func addSubTask(_ sender: UIButton) {
		/*let currY = self.frame.height
		let frame = CGRect(x: CheckListView.linePaddingHorizontal,
						   y: currY,
						   width: self.frame.width - 2 * CheckListView.linePaddingHorizontal,
						   height: CheckListView.lineHeight)
		let newLine = CheckListViewLine(task: nil, frame: frame)*/
		
		if parentTask.subTasks != nil {
			parentTask.subTasks!.append(Task(title: ""))
		} else {
			parentTask.subTasks = [Task(title: "")]
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
		checklist.lines.last?.titleTextField.becomeFirstResponder()
	}
	
	@objc private func removeSubTask(_ sender: UIButton) {
		
	}
	
	
	
	static func getContentHeight(task: TaskCheckList) -> CGFloat {
		let count = task.subTasks?.count
		return count != nil
			? CGFloat(count!) * CheckListView.lineHeight + CGFloat(count! + 1) * CheckListView.linePaddingVertical + CheckListView.toolButtonDimension
			: CheckListView.toolButtonDimension + 2 * CheckListView.linePaddingVertical
	}
	
}

class CheckListViewLine: UIView {
	
	var task: Task! {
		didSet {
			self.titleTextField.text = task.title
		}
	}
	var titleTextField: UITextField!
	var checkButton: UIButton!
	
	init(task: Task, frame: CGRect) {
		super.init(frame: frame)
		initSubviews(task: task)
		self.task = task
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initSubviews(task: nil)
	}
	
	private func initSubviews(task: Task?) {
		let buttonDimension = self.frame.height * 0.6
		let textfield = UITextField(frame: CGRect(x: 10,
												  y: 0,
												  width: self.frame.width - buttonDimension,
												  height: self.frame.height))
		textfield.text = task?.title // task will be nil at this point if empty line is initialized
		let button = UIButton(frame: CGRect(x: self.frame.width - 10 - buttonDimension,
											y: (self.frame.height - buttonDimension) / 2,
											width: buttonDimension,
											height: buttonDimension))
		button.addTarget(self, action: #selector(setDoneSubtask), for: .touchUpInside)
		
		self.addSubview(textfield)
		self.addSubview(button)
		self.titleTextField = textfield
		self.checkButton = button
		
	}
	
	@objc private func setDoneSubtask(_ sender: UIButton) {
		
	}
	
}
