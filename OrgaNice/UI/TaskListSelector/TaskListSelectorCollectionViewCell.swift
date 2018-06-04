//
//  TaskListSelectorCollectionViewCell.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 03.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskListSelectorCollectionViewCell: UICollectionViewCell {
	
	//MARK: Properties
	var taskList: TaskList! {
		didSet {
			self.titleLabel.text = taskList.title
			self.taskCountLabel.text = "ToDo: \(taskList.countUndone())"
		}
	}
	
	//MARK: Outlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var taskCountLabel: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.backgroundColor = UIColor.lightGray
		self.layer.borderColor = UIColor.black.cgColor
		self.layer.borderWidth = 1.0
		self.layer.cornerRadius = 15
		
		
		self.createGradientLayer(view: self)
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		let customLayoutAttributes = layoutAttributes as! TaskListSelectorCollectionViewLayoutAttributes
		self.layer.anchorPoint = customLayoutAttributes.anchorPoint
		self.center.y += (customLayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
		self.layer.sublayers![0].frame = self.layer.bounds // Scale gradient to cell size
	}
	
	func createGradientLayer(view: UIView) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = view.bounds
		gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
		gradientLayer.locations = [0, 1]
		view.layer.sublayers!.insert(gradientLayer, at: 0)
		//view.layer.sublayers![1].zPosition = 0
	}
	
}
