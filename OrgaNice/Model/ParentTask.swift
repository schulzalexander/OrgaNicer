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
	var subtasks: [BasicTask]?
	var checked: [String: Bool]?
	
	struct PropertyKeys {
		static let subtasks = "subtasks"
		static let checked = "checked"
	}
	
	func addSubTask(task: BasicTask) {
		if self.subtasks == nil {
			self.subtasks = [task]
		} else {
			self.subtasks!.append(task)
		}
	}
	
	func deleteSubTask(id: String) {
		guard self.subtasks != nil else {
			return
		}
		for i in 0..<self.subtasks!.count {
			if self.subtasks![i].id == id {
				self.subtasks!.remove(at: i)
				return
			}
		}
	}
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(subtasks, forKey: PropertyKeys.subtasks)
		aCoder.encode(checked, forKey: PropertyKeys.checked)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.subtasks = aDecoder.decodeObject(forKey: PropertyKeys.subtasks) as? [BasicTask]
		self.checked = aDecoder.decodeObject(forKey: PropertyKeys.checked) as? [String: Bool]
		super.init(coder: aDecoder)
	}
}
