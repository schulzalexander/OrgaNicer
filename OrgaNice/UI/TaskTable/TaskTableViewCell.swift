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
	var task: Task!
	
	//MARK: Outlets
	@IBOutlet weak var titleTextEdit: UITextField!
	@IBOutlet weak var checkButton: UIButton!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		titleTextEdit.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	@IBAction func check(_ sender: UIButton) {
		checkButton.setTitle("X", for: .normal)
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
		checkButton.layer.cornerRadius = 20
		checkButton.layer.borderColor = UIColor.black.cgColor
		checkButton.layer.borderWidth = 1.0
	}
}
