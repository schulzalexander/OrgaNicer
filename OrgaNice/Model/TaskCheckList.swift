//
//  TaskCheckList.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class TaskCheckList: MainTask {
	
	//MARK: Properties
	var subTasks: [Task]?
	
	struct PropertyKeys {
		static let subTasks = "subTasks"
	}
	
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(subTasks, forKey: PropertyKeys.subTasks)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let subTasks = aDecoder.decodeObject(forKey: PropertyKeys.subTasks) as? [Task] else {
			fatalError("Error while decoding object of class TaskCheckList")
		}
		self.subTasks = subTasks
		super.init(coder: aDecoder)
	}
	
}
