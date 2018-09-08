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
	var taskOrdering: [Int]? // contains indexes of tasks in sortedTasks array of category
	
	var pinchCellSizeBuffer: CGFloat!
	var pinchCellBuffer: TaskTableViewCell!
	
	var swipeCategoryCenterPoint: CGPoint?
	
	// status of side menu, static menu points like the "add task" button may still be shown when hidden
	// used to restore menu status after coming back from another viewcontroller
	var isSideMenuHidden: Bool!
	
	var tableTabBar: TableTabBar!
	// Will be set when tableview scrolls to bottom after adding new task
	// in order to set focus on the textView of the last cell
	var tableViewScrollCompletionBlock: (()->())?
	
	
	//MARK: Outlets
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var categorySelector: SelectorCollectionView!
	
	var longPressRecognizer: UILongPressGestureRecognizer! // Will notify the user that reordering is disabled when table has fixed ordering
	
	//MARK: Main View Events
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 11.0, *) {
			self.navigationController?.navigationBar.prefersLargeTitles = true
			self.navigationItem.largeTitleDisplayMode = .automatic
		}
		
		isSideMenuHidden = true
		
		tableView.delegate = self
		tableView.dataSource = self
		tableView.reorder.delegate = self
		tableView.reorder.cellScale = 1.05
		//tableView.rowHeight = UITableView.automaticDimension
		
		/*  Setting footer via delegate methods lets the footer float over bottom
			content of the table, and not be part of it  */
		var footerFrame = categorySelector.bounds
		footerFrame.size.height *= 2
		tableView.tableFooterView = UIView(frame: footerFrame)
		
		longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTableViewLongPress(_:)))
		longPressRecognizer.minimumPressDuration = 0.5
		tableView.addGestureRecognizer(longPressRecognizer)
		
		let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(TaskTableViewController.handlePinch))
		tableView.addGestureRecognizer(pinchRecognizer)
		
		setupTableTabBar()
		
		// Catgory Selector
		categorySelector.delegate = self
		categorySelector.dataSource = TaskCategoryManager.shared
		categorySelector.decelerationRate = 0.1//UIScrollView.decelerationRate(rawValue: 0.1)
		
		// Load first list if existing
		if TaskCategoryManager.shared.categoryTitlesSorted.count > 0 {
			let id = TaskCategoryManager.shared.categoryTitlesSorted[0].id
			if let category = TaskCategoryManager.shared.getTaskCategory(id: id) {
				self.setTaskCategory(category: category)
			}
		}
		setupTransparentGradientBackground()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
		
		if !isSideMenuHidden, let navController = self.navigationController as? TaskTableNavigationController {
			navController.sideMenu.show(showStatic: true)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if currList != nil && currList!.count() > 0 {
			tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
		}
	}
	
	//MARK: Keyboard Events
	@objc func keyboardWillShow(_ notification:Notification) {
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardSize.height + 50, right: 0)
		}
	}
	@objc func keyboardWillHide(_ notification:Notification) {
		tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
	}
	
	func newTask() {
		guard currList != nil, navigationController?.topViewController is TaskTableViewController else {
			return
		}
		if currList!.settings.selectedTaskStatusTab != .undone {
			tableTabBar.switchToTab(index: TaskCategorySettings.TaskStatus.undone.rawValue)
			switchToUndoneTasks()
		}
		let newTask = MainTask(title: "")
		currList!.addTask(task: newTask)
		updateTaskOrdering()
		updateCurrListProgressBar()
		tableView.reloadData()
		
		let newIndexPath = IndexPath(row: taskOrdering!.count - 1, section: 0)
		if let newTaskCell = self.tableView.cellForRow(at: newIndexPath) as? TaskTableViewCell {
			tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
			newTaskCell.titleTextEdit.isEnabled = true
			newTaskCell.titleTextEdit.becomeFirstResponder()
		} else {
			tableViewScrollCompletionBlock = {
				guard let newTaskCell = self.tableView.cellForRow(at: newIndexPath) as? TaskTableViewCell else {
					return
				}
				newTaskCell.titleTextEdit.isEnabled = true
				newTaskCell.titleTextEdit.becomeFirstResponder()
			}
			tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
		}
	}
	
	func setTaskCategory(category: TaskCategory?) {
		self.currList = category
		self.navigationItem.title = category?.title
		if category != nil {
			self.tableTabBar.switchToTab(index: category!.settings.selectedTaskStatusTab.rawValue)
		}
		self.updateTaskOrdering()
		self.longPressRecognizer.isEnabled = (self.currList?.settings.taskOrder ?? nil) != .custom
		self.tableView.reorder.isEnabled = (self.currList?.settings.taskOrder ?? nil) == .custom
		self.tableView.reloadData()
	}
	
	func updateTaskCategoryProgressbar() {
		guard currList != nil else {
			return
		}
		for cell in categorySelector.visibleCells {
			if let categoryCell = cell as? SelectorCollectionViewCell,
				categoryCell.category.id == currList!.id {
				categoryCell.setupGradientLayer()
				break
			}
		}
	}
	
	@IBAction func toggleSideMenu(_ sender: UIBarButtonItem) {
		guard let navController = navigationController as? TaskTableNavigationController else {
			return
		}
		navController.sideMenu.toggle()
		isSideMenuHidden = !isSideMenuHidden
	}
	
	@objc func handleTableViewLongPress(_ sender: UILongPressGestureRecognizer) {
		if sender.state == .began {
			let alertController = UIAlertController(title: NSLocalizedString("Oops", comment: ""),
													message: NSLocalizedString("SortingNotPossibleMessage", comment: ""),
													preferredStyle: .alert)
			let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
			alertController.addAction(cancel)
			DispatchQueue.main.async {
				self.present(alertController, animated: true, completion: nil)
			}
		}
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
			TaskArchive.saveTaskCategory(list: self.currList!)
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
			let viewController = storyboard?.instantiateViewController(withIdentifier: "TaskSettingsTableViewController") as? TaskSettingsTableViewController else {
				return
		}
		viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
		viewController.modalPresentationStyle = UIModalPresentationStyle.popover
		viewController.task = cell.task
		
		let popover = viewController.popoverPresentationController
		popover?.delegate = self
		popover?.sourceView = view
		popover?.sourceRect = CGRect(x: view.center.x, y: view.center.y, width: 0, height: 0)
		popover?.permittedArrowDirections = .init(rawValue: 0)
		
		self.present(viewController, animated: true, completion: nil)
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
	
	func updateTaskOrdering() {
		guard let currList = currList else {
			self.taskOrdering = nil
			return
		}
		self.taskOrdering = currList.settings.taskOrder == .custom
			? currList.getOrderForStatus(done: currList.settings.seperateByTaskStatus
				? currList.settings.selectedTaskStatusTab == .done
				: nil)
			: currList.getOrderByDueDate(done: currList.settings.seperateByTaskStatus
				? currList.settings.selectedTaskStatusTab == .done
				: nil)
	}
	
	func updateCurrListProgressBar() {
		for cell in categorySelector.visibleCells {
			if let categoryCell = cell as? SelectorCollectionViewCell,
				currList != nil,
				categoryCell.category.id == currList!.id {
				categoryCell.setupGradientLayer()
				break
			}
		}
	}
	
	//MARK: Private Methods
	
	private func setupFilterBar() {
		let nibName = UINib(nibName: "CustomHeaderView", bundle: nil)
		self.tableView.register(nibName, forHeaderFooterViewReuseIdentifier: "CustomHeaderView")
	}
	
	private func setupTableTabBar() {
		let rect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30)
		tableTabBar = TableTabBar(frame: rect)
		
		tableTabBar.addTab(title: NSLocalizedString("Open", comment: ""), action: {
			self.switchToUndoneTasks()
		})
		tableTabBar.addTab(title: NSLocalizedString("Done", comment: ""), action: {
			self.switchToDoneTasks()
		})
	}
	
	private func switchToUndoneTasks() {
		guard self.currList != nil else {
			return
		}
		self.currList?.settings.selectedTaskStatusTab = .undone
		self.updateTaskOrdering()
		self.tableView.reloadData()
	}
	
	private func switchToDoneTasks() {
		guard self.currList != nil else {
			return
		}
		self.currList?.settings.selectedTaskStatusTab = .done
		self.updateTaskOrdering()
		self.tableView.reloadData()
	}
	
	private func presentCategorySettingsView(category: TaskCategory) {
		guard self.presentedViewController == nil,
			let viewController = storyboard?.instantiateViewController(withIdentifier: "TaskCategorySettingsTableViewController") as? TaskCategorySettingsTableViewController else {
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
	
	private func setupTransparentGradientBackground() {
		let colours:[CGColor] = [UIColor.lightGray.withAlphaComponent(0.1).cgColor, UIColor.white.cgColor]
		let locations:[NSNumber] = [0, 0.6]
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = colours
		gradientLayer.locations = locations
		gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		gradientLayer.frame = self.view.bounds
		
		let view = UIView(frame: self.view.bounds)
		view.layer.addSublayer(gradientLayer)
		self.tableView.backgroundView = view
	}
	
}

//TODO: Move to TaskManager, assign task to cell
extension TaskTableViewController: UITableViewDelegate, UITableViewDataSource {
	
	static let extensionBottomPadding: CGFloat = 20 // padding below taskExtension
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let task = TaskManager.shared.getTask(id: currList!.tasks![taskOrdering![indexPath.row]]) as? MainTask else {
			fatalError("Failed to retrieve task \(currList!.tasks![taskOrdering![indexPath.row]]) while specifying row height.")
		}
		var height = task.cellHeight
		if task is TaskCheckList || task is TaskConsecutiveList {
			height += task.getTaskExtensionHeight() + TaskTableViewController.extensionBottomPadding
		}
		return height
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		updateTodoCounter()
		return taskOrdering?.count ?? 0
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
		guard let task = TaskManager.shared.getTask(id: currList!.tasks![taskOrdering![indexPath.row]]) as? MainTask else {
			fatalError("Type error while loading task for cell setup.")
		}
		cell.task = task
		cell.adjustTitleFont()
		cell.contentView.backgroundColor = Utils.getTaskCellColor(priority: cell.task.cellHeight)
		cell.updateCellExtension()
		
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(TaskTableViewController.didTapOnTaskCell(_:)))
		cell.addGestureRecognizer(recognizer)
		cell.backgroundColor = UIColor.clear
		return cell
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		return (currList?.settings.seperateByTaskStatus ?? false) ? tableTabBar : nil
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return (currList?.settings.seperateByTaskStatus ?? false) ? tableTabBar.bounds.height : 0
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
		let task = self.currList!.tasks![taskOrdering![sourceIndexPath.row]]
		let neighbourNodeIndex = taskOrdering![destinationIndexPath.row]
		if sourceIndexPath.row < destinationIndexPath.row {
			// Moved to the back -> insert behind neighbour
			currList!.tasks!.insert(task, at: neighbourNodeIndex + 1)
			currList!.tasks!.remove(at: taskOrdering![sourceIndexPath.row])
		} else {
			// Moved to the front -> insert before neighbour
			currList!.tasks!.insert(task, at: neighbourNodeIndex)
			currList!.tasks!.remove(at: taskOrdering![sourceIndexPath.row] + 1)
		}
		self.updateTaskOrdering()
	}
	
}

extension TaskTableViewController: UICollectionViewDelegate, UIScrollViewDelegate {
	
	@objc func didTapOnTaskCategory(_ sender: UITapGestureRecognizer) {
		guard let cell = sender.view as? SelectorCollectionViewCell else {
			fatalError("Error while retreiving SelectorCollectionViewCell from TapGestureRecognizer!")
		}
		self.setTaskCategory(category: cell.category)
		if let index = TaskCategoryManager.shared.getTaskCategoryIndex(id: cell.category.id) {
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
		
		// Make sure center point buffer is set
		if self.swipeCategoryCenterPoint == nil {
			if sender.state == .began {
				self.swipeCategoryCenterPoint = cell.center
			} else {
				return
			}
		}

		// Move cell along with swiping finger in y direction
		let maxMovement: CGFloat = 20
		cell.center.y = min(max(self.swipeCategoryCenterPoint!.y + sender.translation(in: self.view).y,
								self.swipeCategoryCenterPoint!.y - maxMovement),
							self.swipeCategoryCenterPoint!.y)
		
		if cell.center.y <= self.swipeCategoryCenterPoint!.y - maxMovement {
			self.presentCategorySettingsView(category: cell.category)
			
			sender.isEnabled = false
			UIView.animate(withDuration: 0.2, animations: {
				cell.center.y = self.swipeCategoryCenterPoint!.y
			}) { (error) in
				sender.isEnabled = true
				self.swipeCategoryCenterPoint = nil
			}
		}
		
		if sender.state == .ended {
			UIView.animate(withDuration: 0.2) {
				cell.center.y = self.swipeCategoryCenterPoint!.y
			}
			self.swipeCategoryCenterPoint = nil
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
			self.categorySelector.layoutIfNeeded()
			if let index = TaskCategoryManager.shared.getTaskCategoryIndex(id: category.id) {
				self.categorySelector.scrollToIndex(index: index)
			}
			
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









