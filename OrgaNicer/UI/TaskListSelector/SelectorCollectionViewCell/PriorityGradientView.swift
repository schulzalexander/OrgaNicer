//
//  RadialGradientLayer.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 11.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class PriorityGradientView: UIView {
	
	//MARK: Properties
	var topGradient: CAGradientLayer!
	
	init(frame: CGRect, taskPriority: CGFloat?) {
		super.init(frame: frame)
		
		topGradient = CAGradientLayer()
		self.layer.addSublayer(topGradient)
		updatePriority(priority: taskPriority)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func updatePriority(priority: CGFloat?) {
		let prioColor = priority != nil ? Utils.getTaskCellColor(priority: priority!).cgColor : Theme.categoryCellBackgroundColor
		topGradient.colors = [prioColor, Theme.categoryCellBackgroundColor]
		topGradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		topGradient.locations = [0, 0.5]
		topGradient.startPoint = CGPoint(x: 0.5, y: 0)
		topGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
	}
	
}
