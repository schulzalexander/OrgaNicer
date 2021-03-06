//
//  TaskArchive.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 01.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskArchive {
	static let TASKDIR: String = "Tasks"
	static let TASKMANAGERDIR: String = "TaskManager"
	static let TASKLISTDIR: String = "TaskCategory"
	static let TASKLISTMANAGERDIR: String = "TaskCategoryManager"
	
	static func taskDir(taskID: String) -> URL {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Failed to retrieve task archive URL!")
		}
		return url.appendingPathComponent(TASKDIR).appendingPathComponent(taskID)
	}
	
	static func saveTask(task: Task) {
		let success = NSKeyedArchiver.archiveRootObject(task, toFile: taskDir(taskID: task.id).path)
		if !success {
			fatalError("Error while saving task \(task.id)!")
		}
	}
	
	static func loadTask(id: String) -> Task? {
		return NSKeyedUnarchiver.unarchiveObject(withFile: taskDir(taskID: id).path) as? Task
	}
	
	static func deleteTask(id: String) {
		do {
			try FileManager.default.removeItem(at: taskDir(taskID: id))
		} catch let error as NSError {
			fatalError("Error while deleting task \(id): \(error.localizedDescription)")
		}
	}
	
	//MARK: TaskManager
	static func taskManagerDir() -> URL {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Failed to retrieve task manager archive URL!")
		}
		return url.appendingPathComponent(TASKMANAGERDIR)
	}
	
	static func saveTaskManager() {
		let success = NSKeyedArchiver.archiveRootObject(TaskManager.shared, toFile: taskManagerDir().path)
		if !success {
			fatalError("Error while saving task manager!")
		}
	}
	
	static func loadTaskManager() -> TaskManager? {
		return NSKeyedUnarchiver.unarchiveObject(withFile: taskManagerDir().path) as? TaskManager
	}
	
	//MARK: TaskCategory
	static func categoryDir(id: String) -> URL {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Failed to retrieve task archive URL!")
		}
		return url.appendingPathComponent(TASKLISTDIR).appendingPathComponent(id)
	}
	
	static func saveTaskCategory(list: TaskCategory) {
		let success = NSKeyedArchiver.archiveRootObject(list, toFile: categoryDir(id: list.id).path)
		if !success {
			fatalError("Error while saving task list \(list.id)!")
		}
	}
	
	static func loadTaskCategory(id: String) -> TaskCategory? {
		return NSKeyedUnarchiver.unarchiveObject(withFile: categoryDir(id: id).path) as? TaskCategory
	}
	
	static func deleteTaskCategory(id: String) {
		do {
			try FileManager.default.removeItem(at: categoryDir(id: id))
		} catch let error as NSError {
			fatalError("Error while deleting task list \(id): \(error.localizedDescription)")
		}
	}
	
	//MARK: TaskManager
	static func categoryManagerDir() -> URL {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Failed to retrieve task list manager archive URL!")
		}
		return url.appendingPathComponent(TASKLISTMANAGERDIR)
	}
	
	static func saveTaskCategoryManager() {
		let success = NSKeyedArchiver.archiveRootObject(TaskCategoryManager.shared, toFile: categoryManagerDir().path)
		if !success {
			fatalError("Error while saving task list manager!")
		}
	}
	
	static func loadTaskCategoryManager() -> TaskCategoryManager? {
		return NSKeyedUnarchiver.unarchiveObject(withFile: categoryManagerDir().path) as? TaskCategoryManager
	}
	
	static func createArchiveBaseDirectories() {
		let catDir = categoryDir(id: "")
		let tskDir = taskDir(taskID: "")
		do {
			if !FileManager.default.fileExists(atPath: catDir.path) {
				try FileManager.default.createDirectory(at: catDir, withIntermediateDirectories: false, attributes: nil)
			}
			if !FileManager.default.fileExists(atPath: tskDir.path) {
				try FileManager.default.createDirectory(at: tskDir, withIntermediateDirectories: false, attributes: nil)
			}
		} catch let error as NSError {
			print("Error: \(error.localizedDescription)")
		}
	}
	
}














