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
	var bottomGradient: CAGradientLayer!
	
	init(frame: CGRect, taskPriority: CGFloat?) {
		super.init(frame: frame)
		
		topGradient = CAGradientLayer()
		bottomGradient = CAGradientLayer()
		self.layer.addSublayer(topGradient)
//		self.layer.addSublayer(bottomGradient)
		updatePriority(priority: taskPriority)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func updatePriority(priority: CGFloat?) {
		let prioColor = priority != nil ? Utils.getTaskCellColor(priority: priority!).cgColor : UIColor.white.cgColor
		topGradient.colors = [prioColor, UIColor.white.cgColor]
		bottomGradient.colors = [UIColor.white.cgColor, prioColor]
		topGradient.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		bottomGradient.frame = CGRect(x: 0, y: bounds.height / 2, width: bounds.width, height: bounds.height / 2)
		topGradient.locations = [0, 0.5]
		bottomGradient.locations = [0.5, 1]
		topGradient.startPoint = CGPoint(x: 0.5, y: 0)
		bottomGradient.startPoint = CGPoint(x: 0.5, y: 0)
		topGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
		bottomGradient.endPoint = CGPoint(x: 0.5, y: 1.0)
	}
	
}
