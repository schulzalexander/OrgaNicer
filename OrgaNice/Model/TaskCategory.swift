//
//  TaskCategory.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskCategory: NSObject, NSCoding {
	
	struct FilterTab {
		static let CUSTOM = 0
		static let DUEDATE = 1
	}
	
	//MARK: Properties
	var tasks: [String]?
	var id: String
	var title: String
	var filterTab: Int
	
	struct PropertyKeys {
		static let taskIDs = "taskIDs"
		static let id = "id"
		static let title = "title"
		static let filterTab = "filterTab"
	}
	
	//MARK: Methods
	
	init(title: String) {
		self.id = Utils.generateID()
		self.title = title
		self.filterTab = FilterTab.CUSTOM
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
			if task.deadline!.date >= from && task.deadline!.date <= to {
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
	
	func getOrderByDueDate() -> [Int] {
		guard tasks != nil else {
			return [Int]()
		}
		var sortedTasks = Array(Zip2Sequence(_sequence1: 0..<tasks!.count, _sequence2: getTasks()))
		sortedTasks.sort { (a, b) -> Bool in
			// either only b or both a and b have no deadline
			if a.1.deadline == nil && b.1.deadline == nil {
				return a.1.created < b.1.created
			} else if a.1.deadline != nil && b.1.deadline == nil {
				return true
			} else if a.1.deadline == nil && b.1.deadline != nil {
				return false
			} else {
				return a.1.deadline!.date < b.1.deadline!.date
			}
		}
		return sortedTasks.map { tuple in
			tuple.0
		}
	}
	
	func getTasks() -> [Task] {
		var ret = [Task]()
		guard tasks != nil else {
			return ret
		}
		for id in tasks! {
			if let newTask = TaskManager.shared.getTask(id: id) {
				ret.append(newTask)
			}
		}
		return ret
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(tasks, forKey: PropertyKeys.taskIDs)
		aCoder.encode(id, forKey: PropertyKeys.id)
		aCoder.encode(title, forKey: PropertyKeys.title)
		aCoder.encode(filterTab, forKey: PropertyKeys.filterTab)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let id = aDecoder.decodeObject(forKey: PropertyKeys.id) as? String,
			let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String else {
			fatalError("Error while loading task list from storage!")
		}
		self.id = id
		self.title = title
		self.filterTab = aDecoder.decodeInteger(forKey: PropertyKeys.filterTab)
		self.tasks = aDecoder.decodeObject(forKey: PropertyKeys.taskIDs) as? [String]
	}
	
}




















