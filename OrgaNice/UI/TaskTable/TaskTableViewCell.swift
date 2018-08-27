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
	var task: MainTask! {
		didSet {
			self.titleTextEdit.text = task.title
			if task.title.count != 0 {
				self.titleTextEdit.isEnabled = false
			}
			self.deadlineLabel.text = task.isDone()
				? NSLocalizedString("Done", comment: "").uppercased()
				: task.deadline?.getDueString()
			self.reloadCheckBoxContent()
			self.contentView.backgroundColor = Utils.getTaskCellColor(priority: self.task.cellHeight)
			self.adjustTitleFont()
			self.seperator.frame = getSeperatorFrame()
			self.updateCellExtension()
		}
	}
	var cellExtension: TaskTableViewCellContent?
	var seperator: UIView!
	
	//MARK: Outlets
	@IBOutlet weak var titleTextEdit: UITextField!
	@IBOutlet weak var checkButton: UIButton!
	@IBOutlet weak var deadlineLabel: UILabel!
	@IBOutlet weak var extensionButton: UIButton!
	
	static let PADDING_X: CGFloat = 5
	static let PADDING_Y: CGFloat = 5
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		self.titleTextEdit.delegate = self
		self.setupCheckButton()
		self.setupBackgroundView()
		self.addSeperator()
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
			: task.deadline?.getDueString() ?? ""
		guard let tableView = self.superview as? UITableView,
			let viewController = tableView.delegate as? TaskTableViewController else {
				return
		}
		viewController.updateTodoCounter()
		viewController.updateTaskOrdering()
		viewController.tableView.reloadData()
	}
	
	@IBAction func didPressExtensionButton(_ sender: UIButton) {
		guard let tableView = superview as? UITableView,
			let viewController = tableView.delegate as? TaskTableViewController,
			let index = getIndexInTableView() else {
				fatalError("Could not retrieve tableView as superview of tableViewCell!")
		}
		let decisionMenu = OverlayDecisionView(presenter: viewController.navigationController!, cancelPosition: .center)
		decisionMenu.addOption(title: "Checklist") {
			let newTask = TaskCheckList(task: self.task)
			TaskManager.shared.addTask(task: newTask)
			tableView.reloadRows(at: [index], with: .automatic)
		}
		decisionMenu.addOption(title: "Follow Up") {
			let newTask = TaskConsecutiveList(task: self.task)
			TaskManager.shared.addTask(task: newTask)
			tableView.reloadRows(at: [index], with: .automatic)
		}
		decisionMenu.show()
	}
	
	//MARK: TextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let newTitle = textField.text!
		if newTitle != task.title {
			task.title = newTitle
			TaskArchive.saveTask(task: task)
		}
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		guard textField.text != nil, textField.text!.count > 0 else {
			guard let tableView = superview as? UITableView,
				let viewController = tableView.delegate as? TaskTableViewController else {
					fatalError("Could not retrieve tableView as superview of tableViewCell!")
			}
			viewController.currList!.deleteTask(id: task.id)
			viewController.updateTaskOrdering()
			tableView.reloadData()
			return
		}
		textField.text = task.title
		// Disable textfield once the title was inserted to make for a bigger surface for tap gesture
		// Title can be changed in the Task Settings afterwards
		textField.isEnabled = false
	}
	
	func updateAppearance(newHeight: CGFloat) {
		let scaledHeight = Utils.getTaskCellHeight(priority: newHeight)
		self.task.cellHeight = scaledHeight
		self.contentView.backgroundColor = Utils.getTaskCellColor(priority: scaledHeight)
	}
	
	func adjustTitleFont() {
		guard task != nil else {
			return
		}
		let fontSize = Utils.getTaskCellTextSize(priority: task.cellHeight)
		self.titleTextEdit.font = self.titleTextEdit.font!.withSize(fontSize)
		self.deadlineLabel.font = self.deadlineLabel.font.withSize(min(fontSize - 5, 20))
		let fontColor = Utils.getTaskCellFontColor(priority: task.cellHeight)
		self.titleTextEdit.textColor = fontColor
		self.deadlineLabel.textColor = fontColor
		self.extensionButton.setTitleColor(fontColor, for: .normal)
		self.titleTextEdit.sizeToFit()
	}
	
	func startPinchMode() {
		self.titleTextEdit.isHidden = true
		self.deadlineLabel.isHidden = true
		self.seperator.isHidden = true
		self.cellExtension?.isHidden = true
	}
	
	func endPinchMode() {
		self.titleTextEdit.isHidden = false
		self.deadlineLabel.isHidden = false
		self.adjustTitleFont()
		self.seperator.frame = getSeperatorFrame()
		self.seperator.isHidden = false
		self.cellExtension?.isHidden = false
		self.updateCellExtension()
	}
	
	func updateCellExtension() {
		// Remove prior task extensions (e.g. checklists)
		for subview in self.subviews {
			if subview is CheckListView || subview is ConsecutiveListView {
				subview.removeFromSuperview()
			}
		}
		
		let extensionFrame = CGRect(x: self.titleTextEdit.frame.minX,
									y: self.contentView.bounds.maxY - task.getTaskExtensionHeight() - (TaskTableViewController.extensionBottomPadding),
									width: self.contentView.bounds.maxX - 30 - self.titleTextEdit.frame.minX,
			height: task.getTaskExtensionHeight())
		if let cellExtension = task.createTaskExtensionView(frame: extensionFrame) {
			self.addSubview(cellExtension)
			self.extensionButton.isHidden = true
			self.cellExtension = cellExtension
			
			cellExtension.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -0.5 * TaskTableViewController.extensionBottomPadding)
		} else {
			self.extensionButton.isHidden = false
		}
	}
	
	//MARK: Private Methods
	
	private func getIndexInTableView() -> IndexPath? {
		guard let tableView = self.superview as? UITableView else {
			fatalError("Error: Failed to retrieve tableview while returning index of cell!")
		}
		return tableView.indexPath(for: self)
	}
	
	private func setupCheckButton() {
		checkButton.layer.cornerRadius = 5
		checkButton.layer.borderColor = UIColor.black.cgColor
		checkButton.layer.borderWidth = 1.0
	}
	
	private func setupBackgroundView() {
		self.contentView.layer.cornerRadius = 20
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
	
	private func getSeperatorFrame() -> CGRect {
		return CGRect(x: self.titleTextEdit.frame.minX,
					  y: self.titleTextEdit.frame.maxY + 5,
					  width: self.contentView.frame.width - self.titleTextEdit.frame.minX - 80,
					  height: 1)
	}
	
	private func addSeperator() {
		let rect = getSeperatorFrame()
		let view = UIView(frame: rect)
		view.backgroundColor = UIColor.white
		self.addSubview(view)
		self.seperator = view
	}
	
}
