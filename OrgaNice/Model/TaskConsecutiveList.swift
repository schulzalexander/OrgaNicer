//
//  TaskConsecutiveList.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class TaskConsecutiveList: MainTask {
	
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
		return ConsecutiveListView(task: self, frame: frame)
	}
	
	override func getTaskExtensionHeight() -> CGFloat {
		return ConsecutiveListView.getContentHeight(task: self)
	}
	
}
