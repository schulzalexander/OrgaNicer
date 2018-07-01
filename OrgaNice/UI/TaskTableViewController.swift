//
//  ViewController.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit
import SwiftReorder

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
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.reorder.delegate = self
		tableView.reorder.cellScale = 1.05
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TaskTableViewController.handlePinch))
		tableView.addGestureRecognizer(pinchRecognizer)
		
		// Catgory Selector
		categorySelector.delegate = self
		categorySelector.dataSource = TaskCategoryManager.shared
		categorySelector.decelerationRate = 0.1
		setupTransparentGradientBackground()
		
		// Load first list if existing
		if TaskCategoryManager.shared.categoryTitlesSorted.count > 0 {
			let id = TaskCategoryManager.shared.categoryTitlesSorted[0].id
			if let category = TaskCategoryManager.shared.getTaskCategory(id: id) {
				self.setTaskCategory(category: category)
			}
		}
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if currList != nil && currList!.count() > 0 {
			tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
		}
	}
	
	func newTask() {
		if currList == nil {
			return
		}
		let newTask = Task(title: "")
		currList!.addTask(task: newTask)
		tableView.reloadData()
		let newIndexPath = IndexPath(row: currList!.count() - 1, section: 0)
		guard let newTaskCell = tableView.cellForRow(at: newIndexPath) as? TaskTableViewCell else {
			return
		}
		tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
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
				let cell = tableView.cellForRow(at: indexPath) as? TaskTableViewCell else {
				return
			}
			pinchCellSizeBuffer = cell.task.cellHeight ?? TaskTableViewController.DEFAULT_CELL_SIZE
			pinchCellBuffer = cell
			pinchCellBuffer.startPinchMode()
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
			pinchCellBuffer.endPinchMode()
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
	
	private func setupTransparentGradientBackground() {
		let colour:UIColor = .white
		let colours:[CGColor] = [colour.withAlphaComponent(0.0).cgColor,colour.cgColor]
		let locations:[NSNumber] = [0, 0.2]
		
		let backgrdView = UIView(frame: self.categorySelector.frame)
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = colours
		gradientLayer.locations = locations
		gradientLayer.frame = self.categorySelector.bounds
		
		backgrdView.layer.addSublayer(gradientLayer)
		self.categorySelector.backgroundView = backgrdView
	}
	
	private func setupFilterBar() {
		let nibName = UINib(nibName: "CustomHeaderView", bundle: nil)
		self.tableView.register(nibName, forHeaderFooterViewReuseIdentifier: "CustomHeaderView")
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
		// TableViewReorder
		if let spacer = tableView.reorder.spacerCell(for: indexPath) {
			return spacer
		}
		
		// Setup normal task cell
		let cellIdentifier = "TaskTableViewCell"
		guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TaskTableViewCell else {
			fatalError("Dequeued cell is not an instance of TaskTableViewCell!")
		}
		cell.task = TaskManager.shared.getTask(id: currList!.tasks![indexPath.row])
		
		return cell
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
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footer = UIView(frame: categorySelector.bounds)
		return footer
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return categorySelector.bounds.height
	}
	
}

extension TaskTableViewController: TableViewReorderDelegate {
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .none
	}
	
	func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		guard self.currList != nil, self.currList!.tasks != nil else {
			return
		}
		let task = self.currList!.tasks!.remove(at: sourceIndexPath.row)
		self.currList!.tasks!.insert(task, at: destinationIndexPath.row)
		TaskArchive.saveTaskCategory(list: self.currList!)
	}
	
}












