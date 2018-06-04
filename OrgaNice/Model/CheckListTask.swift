//
//  CheckListTask.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class CheckListTask: ParentTask {
	//MARK: Properties
	var checkedIDs: [String: Bool]? // id -> checked
	
	struct PropertyKeys {
		static let checkedIDs = "checkedIDs"
	}
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(checkedIDs, forKey: PropertyKeys.checkedIDs)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		self.checkedIDs = aDecoder.decodeObject(forKey: PropertyKeys.checkedIDs) as? [String: Bool]
		super.init(coder: aDecoder)
	}
}
