//
//  ParentTask.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class ParentTask: Task {
	//MARK: Properties
	var subtasks: TaskList
	
	struct PropertyKeys {
		static let subtasks = "subtasks"
	}
	
	override init(title: String) {
		super.init(title: title)
		self.subtasks = TaskList(parentID: self.id)
	}
	
	func addSubTask(task: Task) {
		subtasks.addSubTask(task: task)
	}
	
	func deleteSubTask(id: String) {
		subtasks.deleteSubTask(id: id)
	}
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(subtasks, forKey: PropertyKeys.subtasks)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let subtasks = aDecoder.decodeObject(forKey: PropertyKeys.subtasks) as? TaskList else {
			fatalError("Error while decoding ParentTask object!")
		}
		self.subtasks = subtasks
		super.init(coder: aDecoder)
	}
}
