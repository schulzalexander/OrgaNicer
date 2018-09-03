//
//  TaskCheckList.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class TaskCheckList: MainTask {
	
	//MARK: Properties
	var subTasks: [String]?
	
	struct PropertyKeys {
		static let subTasks = "subTasks"
	}
	
	override init(task: MainTask) {
		super.init(task: task)
	}
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(subTasks, forKey: PropertyKeys.subTasks)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.subTasks = aDecoder.decodeObject(forKey: PropertyKeys.subTasks) as? [String]
		super.init(coder: aDecoder)
	}
	
	func addSubtask(id: String) {
		if subTasks != nil {
			subTasks!.append(id)
		} else {
			subTasks = [id]
		}
		// Don't save because new task might be "empty", when user hasn't given a title yet
	}
	
	func removeSubtask(id: String) {
		for i in 0..<(subTasks?.count ?? 0) {
			if subTasks![i] == id {
				subTasks?.remove(at: i)
				break
			}
		}
	}
	
	//MARK: TaskTableDisplayable
	
	override func createTaskExtensionView(frame: CGRect) -> TaskTableViewCellContent? {
		return CheckListView(task: self, frame: frame)
	}
	
	override func getTaskExtensionHeight() -> CGFloat {
		return CheckListView.getContentHeight(task: self)
	}
	
}
