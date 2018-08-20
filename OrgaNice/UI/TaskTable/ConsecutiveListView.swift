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
	
	init(task: TaskConsecutiveList, frame: CGRect) {
		super.init(frame: frame)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	static func getContentHeight(task: TaskConsecutiveList) -> CGFloat {
		fatalError("Function getContentHeight(task) must be implemented by subclasses of TaskTableViewCellContent!")
	}
	
}
