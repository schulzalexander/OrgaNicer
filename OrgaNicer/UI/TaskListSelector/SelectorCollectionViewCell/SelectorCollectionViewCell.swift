//
//  SelectorCollectionViewCell.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 03.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class SelectorCollectionViewCell: UICollectionViewCell {
	
	//MARK: Properties
	var category: TaskCategory! {
		didSet {
			guard category != nil else {
				return
			}
			self.titleLabel.text = category!.title
			self.updateContent()
		}
	}
	
	//MARK: Outlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var taskCountLabel: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		//self.backgroundColor = .white
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.gray.cgColor
		self.layer.shadowRadius = 5.0
		self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
		self.layer.shadowOpacity = 1.0
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		let customLayoutAttributes = layoutAttributes as! SelectorCollectionViewLayoutAttributes
		self.layer.anchorPoint = customLayoutAttributes.anchorPoint
		self.center.y += (customLayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
		self.layer.sublayers![0].frame = self.layer.bounds // Scale gradient to cell size
	}
	
	//MARK: Content Setup
	
	func updateContent() {
		updateTodoCounter()
		setupProgressbarLayer()
		setupPriorityGradientLayer()
	}
	
	private func updateTodoCounter() {
		self.taskCountLabel.text = "\(NSLocalizedString("Done", comment: "")): \(category.countDone()) / \(category.count())"
	}
	
	//MARK: Appearance
	
	private func setupPriorityGradientLayer() {
		let prioAvg = category.getAverageTaskPriority()
		let gradientLayer = PriorityGradientLayer(taskPriority: prioAvg)
		gradientLayer.frame = self.bounds
		var found = false
		for layer in self.layer.sublayers ?? [] {
			if layer is PriorityGradientLayer {
				self.layer.replaceSublayer(layer, with: gradientLayer)
				found = true
				break
			}
		}
		if !found {
			self.layer.insertSublayer(gradientLayer, at: 0)
		}
	}
	
	private func setupProgressbarLayer() {
		let done = category.countDone()
		let loadedPercentage: CGFloat = done == 0 ? 0 : CGFloat(done) / CGFloat(category.count())
		let progressbarLayer = ProgressbarLayer(loadedPercentage: loadedPercentage)
		progressbarLayer.frame = self.bounds
		var found = false
		for layer in self.layer.sublayers ?? [] {
			if layer is ProgressbarLayer {
				self.layer.replaceSublayer(layer, with: progressbarLayer)
				found = true
				break
			}
		}
		if !found {
			self.layer.insertSublayer(progressbarLayer, at: 0)
		}
	}
	
}









