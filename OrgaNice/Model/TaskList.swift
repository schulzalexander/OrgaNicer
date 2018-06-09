//
//  TaskList.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskList: NSObject, NSCoding {
	
	//MARK: Properties
	var parentID: String
	var subtasks: [String]
	var checked: [String: Bool]
	
	struct PropertyKeys {
		static let parentID = "parentID"
		static let subtasks = "subtasks"
		static let checked = "checked"
	}
	
	init(parentID: String) {
		self.parentID = parentID
		self.subtasks = [String]()
		self.checked = [String: Bool]()
	}
	
	func addSubTask(task: Task) {
		self.subtasks.append(task.id)
		TaskManager.shared.addTask(task: task)
		if let parentTask = TaskManager.shared.getTask(id: self.parentID) {
			TaskArchive.saveTask(task: parentTask)
		}
	}
	
	func deleteSubTask(id: String) {
		for i in 0..<self.subtasks.count {
			if self.subtasks[i] == id {
				self.subtasks.remove(at: i)
				return
			}
		}
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(parentID, forKey: PropertyKeys.parentID)
		aCoder.encode(subtasks, forKey: PropertyKeys.subtasks)
		aCoder.encode(checked, forKey: PropertyKeys.checked)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let parentID = aDecoder.decodeObject(forKey: PropertyKeys.parentID) as? String,
			let subtasks = aDecoder.decodeObject(forKey: PropertyKeys.subtasks) as? [String],
			let checked = aDecoder.decodeObject(forKey: PropertyKeys.checked) as? [String: Bool] else {
			fatalError("Error while decoding TaskList object!")
		}
		self.parentID = parentID
		self.subtasks = subtasks
		self.checked = checked
	}
	
	
}
