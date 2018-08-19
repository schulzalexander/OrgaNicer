//
//  TaskCheckList.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class TaskCheckList: MainTask {
	
	//MARK: Properties
	var subTasks: [Task]?
	
	struct PropertyKeys {
		static let subTasks = "subTasks"
	}
	
	init(task: MainTask) {
		super.init(title: task.title)
		alarm = task.alarm
		created = task.created
		id = task.id
		deadline = task.deadline
		done = task.done
		cellHeight = task.cellHeight
	}
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(subTasks, forKey: PropertyKeys.subTasks)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.subTasks = aDecoder.decodeObject(forKey: PropertyKeys.subTasks) as? [Task]
		super.init(coder: aDecoder)
	}
	
	//MARK: TaskTableDisplayable
	
	override func createTaskExtensionView(frame: CGRect) -> UIView? {
		return CheckListView(task: self, frame: frame)
	}
	
	override func getTaskExtensionHeight() -> CGFloat {
		return CheckListView.getContentHeight(task: self)
	}
	
}
