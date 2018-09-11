//
//  RadialGradientLayer.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 11.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class PriorityGradientLayer: CAGradientLayer {
	
	//MARK: Properties
	var taskPriority: CGFloat?
	
	override var frame: CGRect {
		didSet {
			setupAppearance()
		}
	}
	
	init(taskPriority: CGFloat?) {
		self.taskPriority = taskPriority
		
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func setupAppearance() {
		self.colors = [taskPriority != nil ? Utils.getTaskCellColor(priority: taskPriority!).cgColor : UIColor.white.cgColor, UIColor.white.cgColor]
		self.locations = [0, 0.3]
		self.startPoint = CGPoint(x: 0.5, y: 0)
		self.endPoint = CGPoint(x: 0.5, y: 1.0)
	}
	
}
