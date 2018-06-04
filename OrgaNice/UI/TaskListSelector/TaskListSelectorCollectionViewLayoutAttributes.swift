//
//  TaskListSelectorCollectionViewLayoutAttributes.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 02.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskListSelectorCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

	var anchorPoint = CGPoint(x: 0.5, y: 0.5)
	var angle: CGFloat = 0 {
		didSet {
			zIndex = 1000000 - Int(abs(angle * -1000000))
			transform = CGAffineTransform(rotationAngle: angle)
		}
	}

	override func copy(with zone: NSZone? = nil) -> Any {
		let copiedAttributes: TaskListSelectorCollectionViewLayoutAttributes =
			super.copy(with: zone) as! TaskListSelectorCollectionViewLayoutAttributes
		copiedAttributes.anchorPoint = self.anchorPoint
		copiedAttributes.angle = self.angle
		return copiedAttributes
	}
	
}
