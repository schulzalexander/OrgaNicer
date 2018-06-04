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
	var currList: TaskList?
	
	//MARK: Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var taskListSelector: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.delegate = self
		tableView.dataSource = self
		
		//TaskListManager.shared.addTaskList(list: TaskList(title: "FirstList"))
		
		taskListSelector.delegate = self
		taskListSelector.dataSource = TaskListManager.shared
		taskListSelector.decelerationRate = 0.1
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
	
	func setTaskList(taskList: TaskList) {
		self.currList = taskList
		self.navigationItem.title = taskList.title
		self.tableView.reloadData()
	}
	
	@objc func didTapOnTaskList(_ sender: UITapGestureRecognizer) {
		guard let cell = sender.view as? TaskListSelectorCollectionViewCell else {
			fatalError("Error while retreiving TaskListSelectorCollectionViewCell from TapGestureRecognizer!")
		}
		self.setTaskList(taskList: cell.taskList)
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













