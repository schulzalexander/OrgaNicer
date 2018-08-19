//
//  ConsecutiveListView.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class ConsecutiveListView: TaskTableViewCellContent {
	
	override init(task: MainTask, frame: CGRect) {
		super.init(frame: frame)
		guard let consecTask = task as? TaskConsecutiveList else {
			return
		}
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	static func getContentHeight(task: TaskConsecutiveList) -> CGFloat {
		fatalError("Function getContentHeight(task) must be implemented by subclasses of TaskTableViewCellContent!")
	}
	
}
