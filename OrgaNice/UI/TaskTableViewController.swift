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
	var pinchCellSizeBuffer: CGFloat!
	var pinchCellBuffer: TaskTableViewCell!
	
	static let DEFAULT_CELL_SIZE: CGFloat = 70
	
	//MARK: Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var categorySelector: UICollectionView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		//self.tableView.contentInset = UIEdgeInsetsMake(TaskTableViewCell.PADDING_Y, TaskTableViewCell.PADDING_X, TaskTableViewCell.PADDING_Y, TaskTableViewCell.PADDING_X)
		
		tableView.delegate = self
		tableView.dataSource = self
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TaskTableViewController.handlePinch))
		tableView.addGestureRecognizer(pinchRecognizer)
		
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
	
	@objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
		if sender.state == .began {
			let touchCenter = CGPoint(x: (sender.location(ofTouch: 0, in: tableView).x
										+ sender.location(ofTouch: 1, in: tableView).x) / 2,
									  y: (sender.location(ofTouch: 0, in: tableView).y
										+ sender.location(ofTouch: 1, in: tableView).y) / 2)
			guard let indexPath = tableView.indexPathForRow(at: touchCenter),
				let cell = tableView.visibleCells[indexPath.row] as? TaskTableViewCell else {
				return
			}
			pinchCellSizeBuffer = cell.task.cellHeight ?? TaskTableViewController.DEFAULT_CELL_SIZE
			pinchCellBuffer = cell
		}
		guard pinchCellBuffer != nil,
			pinchCellSizeBuffer != nil else {
			return
		}
		
		let newHeight = pinchCellSizeBuffer * sender.scale
		pinchCellBuffer.updateAppearance(newHeight: newHeight)
		
		tableView.beginUpdates()
		tableView.endUpdates()
		
		if sender.state == .ended {
			TaskArchive.saveTask(task: pinchCellBuffer.task)
		}
	}
	
	@objc func didTapOnTaskCategory(_ sender: UITapGestureRecognizer) {
		guard let cell = sender.view as? SelectorCollectionViewCell else {
			fatalError("Error while retreiving SelectorCollectionViewCell from TapGestureRecognizer!")
		}
		self.setTaskCategory(category: cell.category)
	}
	
	@objc func didTapOnAddCategory(_ sender: UITapGestureRecognizer) {
		let alertController = UIAlertController(title: NSLocalizedString("NewCategoryAlertControllerTitle", comment: ""), message: NSLocalizedString("NewCategoryAlertControllerMessage", comment: ""), preferredStyle: .alert)
		let create = UIAlertAction(title: NSLocalizedString("Send", comment: ""), style: .default, handler: { (action) in
			let name = alertController.textFields![0].text ?? ""
			if name.count == 0 {
				return
			}
			let category = TaskCategory(title: name)
			TaskCategoryManager.shared.addTaskCategory(list: category)
			self.categorySelector.reloadData()
			self.setTaskCategory(category: category)
		})
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(create)
		alertController.addAction(cancel)
		alertController.addTextField { (textField) in
			textField.placeholder = NSLocalizedString("Name", comment: "")
		}
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
}

//TODO: Move to TaskManager, assign task to cell
extension TaskTableViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return TaskManager.shared.getTask(id: currList!.tasks![indexPath.row])?.cellHeight ?? TaskTableViewController.DEFAULT_CELL_SIZE
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
	
	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		
		let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (rowAction, indexPath) in
			guard let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else {
				fatalError("Error while retrieving TaskTableViewCell from tableView!")
			}
			self.currList!.deleteTask(id: cell.task.id)
		}
		
		return [deleteAction]
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
}













