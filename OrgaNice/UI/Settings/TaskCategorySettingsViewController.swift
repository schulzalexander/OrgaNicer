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
	@IBOutlet weak var deleteButton: UIButton!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryHeaderTextField.text = category.title
		self.categoryHeaderTextField.delegate = self
		
		self.setupDeleteButton()
		
		self.tableView.tableFooterView = UIView()
    }
	
	@IBAction func deleteList(_ sender: UIButton) {
		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let delete = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive, handler: { (action) in
			TaskCategoryManager.shared.deleteTaskCategory(id: self.category.id)
			self.dismiss(animated: true, completion: nil)
			
			guard let taskTable = self.popoverPresentationController?.delegate as? TaskTableViewController else {
				return
			}
			if TaskCategoryManager.shared.categoryTitlesSorted.count > 0 {
				let id = TaskCategoryManager.shared.categoryTitlesSorted[0].id
				let category = TaskCategoryManager.shared.getTaskCategory(id: id)
				taskTable.setTaskCategory(category: category)
			} else {
				taskTable.setTaskCategory(category: nil)
			}
			taskTable.categorySelector.reloadData()
		})
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(delete)
		alertController.addAction(cancel)
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	private func updateTaskTable() {
		guard let viewController = self.popoverPresentationController?.delegate as? TaskTableViewController else {
			return
		}
		viewController.title = category.title
		viewController.categorySelector.reloadData()
	}
	
	private func setupDeleteButton() {
		deleteButton.backgroundColor = UIColor.red
		deleteButton.layer.cornerRadius = deleteButton.frame.height / 2
		deleteButton.clipsToBounds = true
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
