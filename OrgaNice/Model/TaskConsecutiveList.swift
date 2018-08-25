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
	
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(subTasks, forKey: PropertyKeys.subTasks)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.subTasks = aDecoder.decodeObject(forKey: PropertyKeys.subTasks) as? [String]
		super.init(coder: aDecoder)
	}
	
	//MARK: TaskTableDisplayable
	
	override func createTaskExtensionView(frame: CGRect) -> TaskTableViewCellContent? {
		return nil
	}
	
	override func getTaskExtensionHeight() -> CGFloat {
		return 0
	}
	
}
