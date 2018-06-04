//
//  TaskListManager.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 01.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class TaskListManager: NSObject, NSCoding {
	
	//MARK: Properties
	var taskLists: [String: TaskList]
	var taskListTitlesSorted: [(id: String, title: String)]
	
	static var shared = TaskListManager()
	
	struct PropertyKeys {
		static let taskListIDs = "taskListIDs"
	}
	
	private override init() {
		self.taskLists = [String: TaskList]()
		self.taskListTitlesSorted = [(id: String, title: String)]()
	}
	
	func deleteTaskList(id: String) {
		taskLists.removeValue(forKey: id)
		TaskArchive.deleteTaskList(id: id)
		TaskArchive.saveTaskListManager()
		
		for i in 0..<taskListTitlesSorted.count - 1 {
			if taskListTitlesSorted[i].id == id {
				taskListTitlesSorted.remove(at: i)
				break
			}
		}
	}
	
	func addTaskList(list: TaskList) {
		taskLists[list.id] = list
		TaskArchive.saveTaskList(list: list)
		TaskArchive.saveTaskListManager()
		
		taskListTitlesSorted.append((id: list.id, title: list.title))
		taskListTitlesSorted.sort(by: {$0.id < $1.id})
	}
	
	func count() -> Int {
		return taskLists.count
	}
	
	func getTaskList(id: String) -> TaskList? {
		return taskLists[id]
	}
	
	//MARK: NSCoding
	func encode(with aCoder: NSCoder) {
		aCoder.encode(Array(taskLists.keys), forKey: PropertyKeys.taskListIDs)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let taskListIDs = aDecoder.decodeObject(forKey: PropertyKeys.taskListIDs) as? [String] else {
			fatalError("Error while loading TaskListManager from storage!")
		}
		self.taskLists = [String: TaskList]()
		self.taskListTitlesSorted = [(id: String, title: String)]()
		for id in taskListIDs {
			guard let savedTaskList = TaskArchive.loadTaskList(id: id) else {
				fatalError("Error while loading TaskListManager: task list \(id) couldn't be loaded from storage!")
			}
			self.taskLists[id] = savedTaskList
			self.taskListTitlesSorted.append((id: savedTaskList.id, title: savedTaskList.title))
		}
		self.taskListTitlesSorted.sort(by: {$0.id < $1.id})
	}
	
	
}

extension TaskListManager: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.count()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaskListSelectorCollectionViewCell", for: indexPath) as? TaskListSelectorCollectionViewCell,
			let currView = collectionView.delegate as? TaskTableViewController else {
			fatalError("Error dequeuing cell of type TaskListSelectorCollectionViewCell!")
		}
		let recognizer = UITapGestureRecognizer(target: currView, action: #selector(TaskTableViewController.didTapOnTaskList(_:)))
		cell.addGestureRecognizer(recognizer)
		cell.taskList = self.getTaskList(id: self.taskListTitlesSorted[indexPath.row].id)
		currView.currList = cell.taskList
		return cell
	}
}


















