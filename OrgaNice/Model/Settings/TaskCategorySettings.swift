//
//  TaskCategorySettings.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 15.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskCategorySettings: NSObject, NSCoding {
	
	enum TaskOrder: Int {
		case custom, duedate
	}
	
	enum TaskStatus: Int {
		case undone, done
	}
	
	//MARK: Properties
	var taskOrder: TaskOrder
	var selectedTaskStatusTab: TaskStatus
	
	struct PropertyKeys {
		static let taskOrder = "taskOrder"
		static let selectedTaskStatusTab = "selectedTaskStatusTab"
	}
	
	init(taskOrder: TaskOrder, selectedTaskStatusTab: TaskStatus) {
		self.taskOrder = taskOrder
		self.selectedTaskStatusTab = selectedTaskStatusTab
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(taskOrder.rawValue, forKey: PropertyKeys.taskOrder)
		aCoder.encode(selectedTaskStatusTab.rawValue, forKey: PropertyKeys.selectedTaskStatusTab)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let taskOrder = TaskOrder(rawValue: aDecoder.decodeInteger(forKey: PropertyKeys.taskOrder)),
			let selectedTaskStatusTab = TaskStatus(rawValue: aDecoder.decodeInteger(forKey: PropertyKeys.selectedTaskStatusTab)) else {
			fatalError("Error while decoding object of class TaskCategorySettings")
		}
		self.taskOrder = taskOrder
		self.selectedTaskStatusTab = selectedTaskStatusTab
	}
	
}
