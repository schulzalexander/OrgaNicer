//
//  TaskTableViewCell.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 02.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell, UITextFieldDelegate {

	//MARK: Properties
	var task: Task! {
		didSet {
			self.titleTextEdit.text = task.title
			if task.title.count != 0 {
				self.titleTextEdit.isEnabled = false
			}
			self.deadlineLabel.text = task.isDone()
				? NSLocalizedString("Done", comment: "").uppercased()
				: task.getDueString()
			self.reloadCheckBoxContent()
			self.contentView.backgroundColor = Task.getPriorityColor(priority: self.task.cellHeight)
			self.adjustTitleFont()
		}
	}
	var content: TaskTableViewCellContent?
	
	//MARK: Outlets
	@IBOutlet weak var titleTextEdit: UITextField!
	@IBOutlet weak var checkButton: UIButton!
	@IBOutlet weak var deadlineLabel: UILabel!
	
	static let PADDING_X: CGFloat = 5
	static let PADDING_Y: CGFloat = 5
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		titleTextEdit.delegate = self
		self.setupCheckButton()
		self.setupBackgroundView()
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func check(_ sender: UIButton) {
		if task.isDone() {
			task.setUndone()
		} else {
			task.setDone()
		}
		TaskArchive.saveTask(task: task)
		reloadCheckBoxContent()
		self.deadlineLabel.text = task.isDone()
			? NSLocalizedString("Done", comment: "").uppercased()
			: task.getDueString()
		guard let tableView = self.superview as? UITableView,
			let viewController = tableView.delegate as? TaskTableViewController else {
				return
		}
		viewController.updateTodoCounter()
	}
	
	//MARK: TextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let newTitle = textField.text!
		if Utils.isValidTextInput(text: newTitle) {
			if newTitle != task.title {
				task.title = newTitle
				TaskArchive.saveTask(task: task)
			}
			textField.resignFirstResponder()
		}
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard textField.text != nil, textField.text!.count > 0 else {
			guard let tableView = superview as? UITableView,
				let viewController = tableView.delegate as? TaskTableViewController else {
					fatalError("Could not retrieve tableView as superview of tableViewCell!")
			}
			viewController.currList!.deleteTask(id: task.id)
			tableView.reloadData()
			return
		}
		textField.text = task.title
		// Disable textfield once the title was inserted to make for a bigger surface for tap gesture
		// Title can be changed in the Task Settings afterwards
		textField.isEnabled = false
	}
	
	func updateAppearance(newHeight: CGFloat) {
		let scaledHeight = Task.getPriorityCellHeight(priority: newHeight)
		self.task.cellHeight = scaledHeight
		self.contentView.backgroundColor = Task.getPriorityColor(priority: scaledHeight)
	}
	
	func adjustTitleFont() {
		guard task != nil else {
			return
		}
		let fontSize = Task.getPriorityTextSize(priority: task.cellHeight)
		self.titleTextEdit.font = self.titleTextEdit.font!.withSize(fontSize)
		self.deadlineLabel.font = self.deadlineLabel.font.withSize(min(fontSize - 5, 20))
		let fontColor = Task.getPriorityFontColor(priority: task.cellHeight)
		self.titleTextEdit.textColor = fontColor
		self.deadlineLabel.textColor = fontColor
		self.titleTextEdit.sizeToFit()
	}
	
	func startPinchMode() {
		self.titleTextEdit.isHidden = true
		self.deadlineLabel.isHidden = true
	}
	
	func endPinchMode() {
		self.titleTextEdit.isHidden = false
		self.deadlineLabel.isHidden = false
		adjustTitleFont()
	}
	
	//MARK: Private Methods
	
	private func setupCheckButton() {
		checkButton.layer.cornerRadius = 5
		checkButton.layer.borderColor = UIColor.black.cgColor
		checkButton.layer.borderWidth = 1.0
	}
	
	private func setupBackgroundView() {
		self.contentView.layer.cornerRadius = 20
		//self.contentView.layer.borderColor = UIColor.lightGray.cgColor
		//self.contentView.layer.borderWidth = 1.0
		
		self.contentView.layer.masksToBounds = false
		self.contentView.layer.shadowColor = UIColor.gray.cgColor
		self.contentView.layer.shadowRadius = 3.0
		self.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
		self.contentView.layer.shadowOpacity = 1.0
		
		self.contentView.translatesAutoresizingMaskIntoConstraints = false
		
		self.contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: TaskTableViewCell.PADDING_Y).isActive = true
		self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -1 * TaskTableViewCell.PADDING_Y).isActive = true
		self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: TaskTableViewCell.PADDING_X).isActive = true
		self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -1 * TaskTableViewCell.PADDING_X).isActive = true
	}
	
	private func reloadCheckBoxContent() {
		if task.isDone() {
			checkButton.setTitle("✔️", for: .normal)
		} else {
			checkButton.setTitle(nil, for: .normal)
		}
	}
	
}
