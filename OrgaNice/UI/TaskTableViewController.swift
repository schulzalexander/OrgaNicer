//
//  ViewController.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskTableViewController: UIViewController, UITableViewDelegate, UICollectionViewDelegate {
	
	//MARK: Properties
	var currList: TaskCategory?
	
	//MARK: Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var categorySelector: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.delegate = self
		tableView.dataSource = self
		
		//TaskCategoryManager.shared.addTaskCategory(list: TaskCategory(title: "FirstList"))
		
		categorySelector.delegate = self
		categorySelector.dataSource = TaskCategoryManager.shared
		categorySelector.decelerationRate = 0.1
	}
	
	func newTask() {
		if currList == nil {
			return
		}
		let newTask = Task(title: "")
		currList!.addTask(task: newTask)
		tableView.reloadData()
		guard let newTaskCell = tableView.cellForRow(at: IndexPath(row: currList!.count() - 1, section: 0)) as? TaskTableViewCell else {
			return
		}
		newTaskCell.titleTextEdit.becomeFirstResponder()
	}
	
	func setTaskCategory(category: TaskCategory) {
		self.currList = category
		self.navigationItem.title = category.title
		self.tableView.reloadData()
	}
	
	@objc func didTapOnTaskCategory(_ sender: UITapGestureRecognizer) {
		guard let cell = sender.view as? TaskCategorySelectorCollectionViewCell else {
			fatalError("Error while retreiving TaskCategorySelectorCollectionViewCell from TapGestureRecognizer!")
		}
		self.setTaskCategory(category: cell.category)
	}
}

//TODO: Move to TaskManager, assign task to cell
extension TaskTableViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 62
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return currList != nil ? currList!.count() : 0
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "TaskTableViewCell"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell else {
			fatalError("Dequeued cell is not an instance of TaskTableViewCell!")
		}
		cell.task = TaskManager.shared.getTask(id: currList!.tasks![indexPath.row])
		return cell
	}
	
}













