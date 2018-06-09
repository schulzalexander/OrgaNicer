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
		categories.removeValue(forKey: id)
		TaskArchive.deleteTaskCategory(id: id)
		TaskArchive.saveTaskCategoryManager()
		
		for i in 0..<categoryTitlesSorted.count - 1 {
			if categoryTitlesSorted[i].id == id {
				categoryTitlesSorted.remove(at: i)
				break
			}
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
	
	func getTaskCategory(id: String) -> TaskCategory? {
		return categories[id]
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
		return self.count()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskCategorySelectorCollectionViewCell", for: indexPath) as? TaskCategorySelectorCollectionViewCell,
			let currView = collectionView.delegate as? TaskTableViewController else {
			fatalError("Error dequeuing cell of type TaskCategorySelectorCollectionViewCell!")
		}
		let recognizer = UITapGestureRecognizer(target: currView, action: #selector(TaskTableViewController.didTapOnTaskCategory(_:)))
		cell.addGestureRecognizer(recognizer)
		cell.category = self.getTaskCategory(id: self.categoryTitlesSorted[indexPath.row].id)
		currView.currList = cell.category
		return cell
	}
}


















