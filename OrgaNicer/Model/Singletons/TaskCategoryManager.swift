//
//  TaskCategoryManager.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 01.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class TaskCategoryManager: NSObject, NSCoding {
	
	//MARK: Properties
	var categories: [String: TaskCategory]
	var categoryTitlesSorted: [(id: String, title: String)]
	
	static var shared = TaskCategoryManager()
	
	struct PropertyKeys {
		static let categoryIDs = "categoryIDs"
	}
	
	private override init() {
		self.categories = [String: TaskCategory]()
		self.categoryTitlesSorted = [(id: String, title: String)]()
	}
	
	func deleteTaskCategory(id: String) {
		guard let category = getTaskCategory(id: id) else {
			return
		}
		
		for task in category.tasks ?? [] {
			TaskManager.shared.deleteTask(id: task)
		}
		
		categories.removeValue(forKey: id)
		TaskArchive.deleteTaskCategory(id: id)
		TaskArchive.saveTaskCategoryManager()
		
		if let index = getTaskCategoryIndex(id: id) {
			categoryTitlesSorted.remove(at: index)
		}
	}
	
	func deleteAllTaskCategories() {
		categories.forEach { (key, val) in
			TaskCategoryManager.shared.deleteTaskCategory(id: key)
		}
	}
	
	func addTaskCategory(list: TaskCategory) {
		categories[list.id] = list
		TaskArchive.saveTaskCategory(list: list)
		TaskArchive.saveTaskCategoryManager()
		
		categoryTitlesSorted.append((id: list.id, title: list.title))
		categoryTitlesSorted.sort(by: {$0.id < $1.id})
	}
	
	func count() -> Int {
		return categories.count
	}
	
	func getTaskCategoryIndex(id: String) -> Int? {
		for i in 0..<categoryTitlesSorted.count {
			if categoryTitlesSorted[i].id == id {
				return i
			}
		}
		return nil
	}
	
	func getTaskCategory(id: String) -> TaskCategory? {
		return categories[id]
	}
	
	func getTaskCategoriesContaining(task: String) -> [String] {
		var res = [String]()
		for category in categories {
			if category.value.containsTask(task: task) {
				res.append(category.key)
			}
		}
		return res
	}
	
	// Search for the category of a task and delete it there
	func deleteTask(id: String) {
		for category in categories {
			let index = category.value.tasks?.index(of: id) ?? -1
			if index >= 0 {
				category.value.tasks!.remove(at: index)
				TaskArchive.saveTaskCategory(list: category.value)
				break
			}
		}
	}
	
	//MARK: NSCoding
	func encode(with aCoder: NSCoder) {
		aCoder.encode(Array(categories.keys), forKey: PropertyKeys.categoryIDs)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let categoryIDs = aDecoder.decodeObject(forKey: PropertyKeys.categoryIDs) as? [String] else {
			fatalError("Error while loading TaskCategoryManager from storage!")
		}
		self.categories = [String: TaskCategory]()
		self.categoryTitlesSorted = [(id: String, title: String)]()
		for id in categoryIDs {
			guard let savedTaskCategory = TaskArchive.loadTaskCategory(id: id) else {
				fatalError("Error while loading TaskCategoryManager: task list \(id) couldn't be loaded from storage!")
			}
			self.categories[id] = savedTaskCategory
			self.categoryTitlesSorted.append((id: savedTaskCategory.id, title: savedTaskCategory.title))
		}
		self.categoryTitlesSorted.sort(by: {$0.id < $1.id})
	}
	
	
}

extension TaskCategoryManager: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.count() + 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		//TODO: make this nicer, no duplicated code
		if indexPath.row == self.count() {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectorCollectionViewCellAdd", for: indexPath) as? SelectorCollectionViewCellAdd,
				let currView = collectionView.delegate as? TaskTableViewController else {
					fatalError("Error dequeuing cell of type SelectorCollectionViewCellAdd!")
			}
			let tapRecognizer = UITapGestureRecognizer(target: currView, action: #selector(TaskTableViewController.didTapOnAddCategory(_:)))
			cell.addGestureRecognizer(tapRecognizer)
			return cell
		} else {
			guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectorCollectionViewCell", for: indexPath) as? SelectorCollectionViewCell,
				let currView = collectionView.delegate as? TaskTableViewController else {
					fatalError("Error dequeuing cell of type SelectorCollectionViewCell!")
			}
			
			for recognizer in cell.gestureRecognizers ?? [] {
				cell.removeGestureRecognizer(recognizer)
			}
			
			let tapRecognizer = UITapGestureRecognizer(target: currView, action: #selector(TaskTableViewController.didTapOnTaskCategory(_:)))
			let panRecognizer = UIPanGestureRecognizer(target: currView, action: #selector(TaskTableViewController.didSwipeTaskCategory(_:)))
			tapRecognizer.delegate = currView
			panRecognizer.delegate = currView
			
			cell.addGestureRecognizer(tapRecognizer)
			cell.addGestureRecognizer(panRecognizer)
			cell.category = self.getTaskCategory(id: self.categoryTitlesSorted[indexPath.row].id)
			cell.contentView.layer.cornerRadius = 20
//			cell.clipsToBounds = true
			cell.contentView.layer.masksToBounds = false
			return cell
		}
	}
}


















