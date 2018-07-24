//
//  TaskCategorySettingsViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 22.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskCategorySettingsTableViewController: UITableViewController {

	//MARK: Properties
	var category: TaskCategory!
	
	//MARK: Outlets
	@IBOutlet weak var categoryHeaderTextField: UITextField!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryHeaderTextField.text = category.title
		self.categoryHeaderTextField.delegate = self
    }
	
	private func updateTaskTable() {
		guard let viewController = self.popoverPresentationController?.delegate as? TaskTableViewController else {
			return
		}
		viewController.title = category.title
		viewController.categorySelector.reloadData()
	}
	
}

extension TaskCategorySettingsTableViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if textField.text != nil && textField.text?.count == 0 {
			textField.text = category.title
		} else {
			category.title = textField.text!
			TaskArchive.saveTaskCategory(list: category)
			updateTaskTable()
		}
		return true
	}
}
