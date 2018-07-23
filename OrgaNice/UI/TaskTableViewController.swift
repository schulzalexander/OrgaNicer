//
//  ViewController.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit
import SwiftReorder

class TaskTableViewController: UIViewController, UIPopoverPresentationControllerDelegate {
	
	//MARK: Properties
	var currList: TaskCategory?
	var taskOrdering: [Int]?
	
	var pinchCellSizeBuffer: CGFloat!
	var pinchCellBuffer: TaskTableViewCell!
	
	var swipeCategoryCenterPoint: CGPoint!
	
	var tableTabBar: TableTabBar!
	// Will be set when tableview scrolls to bottom after adding new task
	// in order to set focus on the textView of the last cell
	var tableViewScrollCompletionBlock: (()->())?
	
	
	//MARK: Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var categorySelector: SelectorCollectionView!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.navigationBar.prefersLargeTitles = true
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.reorder.delegate = self
		tableView.reorder.cellScale = 1.05
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 70
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TaskTableViewController.handlePinch))
		tableView.addGestureRecognizer(pinchRecognizer)

		setupTableTabBar()
		
		// Catgory Selector
		categorySelector.delegate = self
		categorySelector.dataSource = TaskCategoryManager.shared
		categorySelector.decelerationRate = 0.1

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
		guard currList != nil else {
			return
		}
		let newTask = Task(title: "")
		currList!.addTask(task: newTask)
		updateTaskOrdering()
		tableView.reloadData()
		let newIndexPath = IndexPath(row: currList!.count() - 1, section: 0)
		if let newTaskCell = self.tableView.cellForRow(at: newIndexPath) as? TaskTableViewCell {
			newTaskCell.titleTextEdit.becomeFirstResponder()
		} else {
			tableViewScrollCompletionBlock = {
				guard let newTaskCell = self.tableView.cellForRow(at: newIndexPath) as? TaskTableViewCell else {
					return
				}
				newTaskCell.titleTextEdit.becomeFirstResponder()
			}
		}
		tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
	}
	
	func setTaskCategory(category: TaskCategory) {
		self.currList = category
		self.tableTabBar.switchToTab(index: category.filterTab)
		self.updateTaskOrdering()
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
			pinchCellSizeBuffer = cell.task.cellHeight
			pinchCellBuffer = cell
			pinchCellBuffer.startPinchMode()
			// Set animations disabled because resizing of certain cells would cause stuttering in tableview
			UIView.setAnimationsEnabled(false)
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
			UIView.setAnimationsEnabled(true)
		}
	}
	
	func updateTodoCounter() {
		if self.currList != nil {
			for cell in categorySelector.visibleCells {
				guard let taskListCell = cell as? SelectorCollectionViewCell else {
					continue
				}
				if taskListCell.category.id == self.currList!.id {
					taskListCell.updateTodoCounter()
					break
				}
			}
		}
	}
	
	@objc func didTapOnTaskCell(_ sender: UITapGestureRecognizer) {
		guard let cell = sender.view as? TaskTableViewCell,
			let viewController = storyboard?.instantiateViewController(withIdentifier: "TaskSettingsViewController") as? TaskSettingsViewController else {
			return
		}
		viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
		viewController.modalPresentationStyle = UIModalPresentationStyle.popover
		viewController.task = cell.task
		
		let popover = viewController.popoverPresentationController
		popover?.delegate = self
		popover?.sourceView = cell
		popover?.sourceRect = cell.bounds
		
		self.present(viewController, animated: true, completion: nil)
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
	
	//MARK: Private Methods
	
	private func setupFilterBar() {
		let nibName = UINib(nibName: "CustomHeaderView", bundle: nil)
		self.tableView.register(nibName, forHeaderFooterViewReuseIdentifier: "CustomHeaderView")
	}
	
	private func setupTableTabBar() {
		let rect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
		tableTabBar = TableTabBar(frame: rect)
		
		tableTabBar.addTab(title: NSLocalizedString("TableTabBarCustomOrder", comment: ""), action: {
			guard self.currList != nil else {
				return
			}
			self.currList!.filterTab = TaskCategory.FilterTab.CUSTOM
			self.updateTaskOrdering()
			self.tableView.reorder.isEnabled = true
			self.tableView.reloadData()
		})
		tableTabBar.addTab(title: NSLocalizedString("TableTabBarDueDateOrder", comment: ""), action: {
			guard self.currList != nil else {
				return
			}
			self.currList!.filterTab = TaskCategory.FilterTab.DUEDATE
			self.updateTaskOrdering()
			self.tableView.reorder.isEnabled = false
			self.tableView.reloadData()
		})
	}
	
	private func updateTaskOrdering() {
		guard currList != nil else {
			return
		}
		self.taskOrdering = currList!.filterTab == TaskCategory.FilterTab.CUSTOM
			? Array(0..<(currList!.tasks?.count ?? 0))
			: currList!.getOrderByDueDate()
	}
	
	private func presentCategorySettingsView(category: TaskCategory) {
		guard self.presentedViewController == nil,
			let viewController = storyboard?.instantiateViewController(withIdentifier: "TaskCategorySettingsViewController") as? TaskCategorySettingsViewController else {
			return
		}
		viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
		viewController.modalPresentationStyle = UIModalPresentationStyle.popover
		viewController.category = category
		
		let popover = viewController.popoverPresentationController
		popover?.delegate = self
		popover?.sourceView = categorySelector
		popover?.sourceRect = categorySelector.bounds
		
		self.present(viewController, animated: true, completion: nil)
	}
	
}

//TODO: Move to TaskManager, assign task to cell
extension TaskTableViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return TaskManager.shared.getTask(id: currList!.tasks![taskOrdering![indexPath.row]])?.cellHeight ?? Task.DEFAULT_CELL_HEIGHT
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		updateTodoCounter()
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
		cell.task = TaskManager.shared.getTask(id: currList!.tasks![taskOrdering![indexPath.row]])
		cell.adjustTitleFontSize()
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(TaskTableViewController.didTapOnTaskCell(_:)))
		cell.addGestureRecognizer(recognizer)
		
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
		return UIView(frame: categorySelector.bounds)
	}
	
	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return categorySelector.bounds.height
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return tableTabBar
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return tableTabBar.bounds.height
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

extension TaskTableViewController: UICollectionViewDelegate, UIScrollViewDelegate {
	
	@objc func didTapOnTaskCategory(_ sender: UITapGestureRecognizer) {
		guard let cell = sender.view as? SelectorCollectionViewCell else {
			fatalError("Error while retreiving SelectorCollectionViewCell from TapGestureRecognizer!")
		}
		self.setTaskCategory(category: cell.category)
		let index = TaskCategoryManager.shared.getTaskCategoryIndex(id: cell.category.id)
		if index >= 0 {
			self.categorySelector.scrollToIndex(index: index)
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if let collectionView = scrollView as? SelectorCollectionView {
			collectionView.scrollToIndex(index: collectionView.getNearestIndex())
		}
	}
	
	func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
		if ((scrollView as? UITableView) != nil) {
			guard tableViewScrollCompletionBlock != nil else {
				return
			}
			tableViewScrollCompletionBlock!()
			tableViewScrollCompletionBlock = nil
		}
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if let collectionView = scrollView as? SelectorCollectionView {
			collectionView.scrollToIndex(index: collectionView.getNearestIndex())
		}
	}
}

extension TaskTableViewController: UIGestureRecognizerDelegate {
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
	//TODO: Doesn't look too nice
	@objc func didSwipeTaskCategory(_ sender: UIPanGestureRecognizer) {
		
		guard let cell = sender.view as? SelectorCollectionViewCell else {
			return
		}
		
		if sender.state == .began {
			self.swipeCategoryCenterPoint = cell.center
		}
		
		cell.center.y = min(max(self.swipeCategoryCenterPoint.y + sender.translation(in: self.view).y,
								self.swipeCategoryCenterPoint.y - 20),
							self.swipeCategoryCenterPoint.y)
		
		if cell.center.y <= self.swipeCategoryCenterPoint.y - 20 {
			self.presentCategorySettingsView(category: cell.category)
			
			sender.isEnabled = false
			sender.isEnabled = true
			UIView.animate(withDuration: 0.2) {
				cell.center.y = self.swipeCategoryCenterPoint.y
			}
		}
		
		if sender.state == .ended {
			UIView.animate(withDuration: 0.2) {
				cell.center.y = self.swipeCategoryCenterPoint.y
			}
		}
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









