//
//  CheckListView.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 08.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class CheckListView: TaskTableViewCellContent {
	
	override init(task: MainTask, frame: CGRect) {
		super.init(frame: frame)
		guard let checkTask = task as? TaskCheckList else {
			return
		}
		self.backgroundColor = UIColor.brown
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	static func getContentHeight(task: TaskCheckList) -> CGFloat {
		return 200
	}
	
}
