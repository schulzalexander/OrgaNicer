//
//  TaskTableViewCellContent.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskTableViewCellContent: UIView {
	
	init(task: MainTask, frame: CGRect) {
		fatalError("Function init(task) must be implemented by subclasses of TaskTableViewCellContent!")
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
}
