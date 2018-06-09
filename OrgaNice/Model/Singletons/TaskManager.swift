//
//  TaskManager.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 01.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskManager: NSObject, NSCoding {
	
	//MARK: Properties
	var tasks: [String: Task]
	
	static var shared = TaskManager()
	
	struct PropertyKeys {
		static let taskIDs = "taskIDs"
	}
	
	
	//MARK: Methods
	private override init() {
		self.tasks = [String: Task]()
	}
	
	func deleteTask(id: String) {
		tasks.removeValue(forKey: id)
		TaskArchive.deleteTask(id: id)
		TaskArchive.saveTaskManager()
	}
	
	func addTask(task: Task) {
		tasks[task.id] = task
		TaskArchive.saveTask(task: task)
		TaskArchive.saveTaskManager()
	}
	
	func countAllTasks() -> Int {
		return tasks.count
	}
	
	func getTask(id: String) -> Task? {
		return tasks[id]
	}
	
	//MARK: NSCoding
	func encode(with aCoder: NSCoder) {
		aCoder.encode(Array(tasks.keys), forKey: PropertyKeys.taskIDs)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let taskIDs = aDecoder.decodeObject(forKey: PropertyKeys.taskIDs) as? [String] else {
			fatalError("Error while loading TaskManager from storage!")
		}
		self.tasks = [String: Task]()
		for id in taskIDs {
			guard let savedTask = TaskArchive.loadTask(id: id) else {
				fatalError("Error while loading TaskManager: task \(id) couldn't be loaded from storage!")
			}
			self.tasks[id] = savedTask
		}
	}
	
	
}








