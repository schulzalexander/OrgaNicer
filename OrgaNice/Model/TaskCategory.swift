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
	var settings: TaskCategorySettings
	
	struct PropertyKeys {
		static let taskIDs = "taskIDs"
		static let id = "id"
		static let title = "title"
		static let settings = "settings"
	}
	
	//MARK: Methods
	
	init(title: String) {
		self.id = Utils.generateID()
		self.title = title
		self.settings = TaskCategorySettings(taskOrder: .custom,
											 selectedTaskStatusTab: .undone)
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
	
	func getOrderByDueDate(done: Bool?) -> [Int] {
		guard tasks != nil else {
			return [Int]()
		}
		let taskList = done != nil ? (done! ? getDone() : getUndone()) : getTasks()
		let indexes = done != nil ? getOrderForStatus(done: done!) : Array(0..<taskList.count)
		var sortedTasks = Array(Zip2Sequence(_sequence1: indexes,_sequence2: taskList))
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
	
	func getOrderForStatus(done: Bool?) -> [Int] {
		guard tasks != nil else {
			return [Int]()
		}
		if done != nil {
			let sortedTasks = Array(Zip2Sequence(_sequence1: 0..<tasks!.count, _sequence2: getTasks()))
			return (sortedTasks.filter { ($1.done != nil) == done }).map({ (tuple) -> Int in
				return tuple.0
			})
		} else {
			return Array(0..<tasks!.count)
		}
	}
	
	func getTasks() -> [Task] {
		return getTasksWithStatus(done: nil)
	}
	
	func getDone() -> [Task] {
		return getTasksWithStatus(done: true)
	}
	
	func getUndone() -> [Task] {
		return getTasksWithStatus(done: false)
	}
	
	private func getTasksWithStatus(done: Bool?) -> [Task] {
		var ret = [Task]()
		guard tasks != nil else {
			return ret
		}
		for id in tasks! {
			if let newTask = TaskManager.shared.getTask(id: id) {
				if done == nil || (newTask.done != nil) == done! {
					ret.append(newTask)
				}
			}
		}
		return ret
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(tasks, forKey: PropertyKeys.taskIDs)
		aCoder.encode(id, forKey: PropertyKeys.id)
		aCoder.encode(title, forKey: PropertyKeys.title)
		aCoder.encode(settings, forKey: PropertyKeys.settings)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let id = aDecoder.decodeObject(forKey: PropertyKeys.id) as? String,
			let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String,
			let settings = aDecoder.decodeObject(forKey: PropertyKeys.settings) as? TaskCategorySettings else {
			fatalError("Error while loading task list from storage!")
		}
		self.id = id
		self.title = title
		self.settings = settings
		self.tasks = aDecoder.decodeObject(forKey: PropertyKeys.taskIDs) as? [String]
	}
	
}




















