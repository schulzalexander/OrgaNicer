//
//  TaskCategorySettings.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 15.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskCategorySettings: NSObject, NSCoding {
	
	enum TaskOrder: Int {
		case duedate, custom
	}
	
	enum TaskStatus: Int {
		case undone, done
	}
	
	//MARK: Properties
	var taskOrder: TaskOrder
	var selectedTaskStatusTab: TaskStatus
	var seperateByTaskStatus: Bool
	
	struct PropertyKeys {
		static let taskOrder = "taskOrder"
		static let selectedTaskStatusTab = "selectedTaskStatusTab"
		static let seperateByTaskStatus = "seperateByTaskStatus"
	}
	
	init(taskOrder: TaskOrder, selectedTaskStatusTab: TaskStatus) {
		self.taskOrder = taskOrder
		self.selectedTaskStatusTab = selectedTaskStatusTab
		self.seperateByTaskStatus = true
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(taskOrder.rawValue, forKey: PropertyKeys.taskOrder)
		aCoder.encode(selectedTaskStatusTab.rawValue, forKey: PropertyKeys.selectedTaskStatusTab)
		aCoder.encode(seperateByTaskStatus, forKey: PropertyKeys.seperateByTaskStatus)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let taskOrder = TaskOrder(rawValue: aDecoder.decodeInteger(forKey: PropertyKeys.taskOrder)),
			let selectedTaskStatusTab = TaskStatus(rawValue: aDecoder.decodeInteger(forKey: PropertyKeys.selectedTaskStatusTab)) else {
			fatalError("Error while decoding object of class TaskCategorySettings")
		}
		self.taskOrder = taskOrder
		self.selectedTaskStatusTab = selectedTaskStatusTab
		self.seperateByTaskStatus = aDecoder.decodeBool(forKey: PropertyKeys.seperateByTaskStatus)
	}
	
}
