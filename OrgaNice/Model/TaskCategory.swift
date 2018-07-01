//
//  TaskCategory.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskCategory: NSObject, NSCoding {
	
	//MARK: Properties
	var tasks: [String]?
	var id: String
	var title: String
	
	struct PropertyKeys {
		static let taskIDs = "taskIDs"
		static let id = "id"
		static let title = "title"
	}
	
	//MARK: Methods
	
	init(title: String) {
		self.id = Utils.generateID()
		self.title = title
	}
	
	func count() -> Int {
		return (tasks ?? []).count
	}
	
	func countDone() -> Int {
		var count = 0
		for id in tasks ?? [] {
			guard let task = TaskManager.shared.getTask(id: id) else {
				continue
			}
			if task.done != nil {
				count += 1
			}
		}
		return count
	}
	
	func countUndone() -> Int {
		var count = 0
		for id in tasks ?? [] {
			guard let task = TaskManager.shared.getTask(id: id) else {
				continue
			}
			if task.done == nil {
				count += 1
			}
		}
		return count
	}
	
	func getTasksDueInTimeframe(from: Date, to: Date) -> [Task] {
		var res = [Task]()
		for id in tasks ?? [] {
			guard let task = TaskManager.shared.getTask(id: id),
				task.deadline != nil else {
				continue
			}
			if task.deadline! >= from && task.deadline! <= to {
				res.append(task)
			}
		}
		return res
	}
	
	func deleteTask(id: String) {
		for i in 0..<(tasks ?? []).count {
			if tasks![i] == id {
				tasks!.remove(at: i)
				TaskManager.shared.deleteTask(id: id)
				break
			}
		}
		TaskArchive.saveTaskCategory(list: self)
	}
	
	func addTask(task: Task) {
		if tasks != nil {
			tasks!.append(task.id)
		} else {
			tasks = [task.id]
		}
		TaskManager.shared.addTask(task: task)
		TaskArchive.saveTaskCategory(list: self)
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(tasks, forKey: PropertyKeys.taskIDs)
		aCoder.encode(id, forKey: PropertyKeys.id)
		aCoder.encode(title, forKey: PropertyKeys.title)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let id = aDecoder.decodeObject(forKey: PropertyKeys.id) as? String,
			let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String else {
			fatalError("Error while loading task list from storage!")
		}
		self.id = id
		self.title = title
		self.tasks = aDecoder.decodeObject(forKey: PropertyKeys.taskIDs) as? [String]
	}
	
}




















