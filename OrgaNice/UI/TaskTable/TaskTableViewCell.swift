//
//  TaskTableViewCell.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 02.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

//TODO: make cell zoomable

import UIKit

class TaskTableViewCell: UITableViewCell, UITextFieldDelegate {

	//MARK: Properties
	var task: Task! {
		didSet {
			self.titleTextEdit.text = task.title
			self.reloadCheckBoxContent()
		}
	}
	var content: TaskTableViewCellContent?
	
	//MARK: Outlets
	@IBOutlet weak var titleTextEdit: UITextField!
	@IBOutlet weak var checkButton: UIButton!
	
	
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
	}
	
	//MARK: TextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		let newTitle = textField.text ?? ""
		if Utils.isValidTextInput(text: newTitle) {
			if newTitle != task.title {
				task.title = newTitle
				TaskArchive.saveTask(task: task)
			}
			textField.resignFirstResponder()
		}
		return true
	}
	
	
	//MARK: Private Methods
	
	private func setupCheckButton() {
		checkButton.layer.cornerRadius = 5
		checkButton.layer.borderColor = UIColor.black.cgColor
		checkButton.layer.borderWidth = 1.0
	}
	
	private func setupBackgroundView() {
		let view = UIView(frame: self.frame)
		view.backgroundColor = UIColor.yellow
		view.layer.cornerRadius = 20
		view.layer.borderColor = UIColor.lightGray.cgColor
		view.layer.borderWidth = 1.0
		self.backgroundView = view
	}
	
	private func reloadCheckBoxContent() {
		if task.isDone() {
			checkButton.setTitle(nil, for: .normal)
		} else {
			checkButton.setTitle("✔️", for: .normal)
		}
	}
}
