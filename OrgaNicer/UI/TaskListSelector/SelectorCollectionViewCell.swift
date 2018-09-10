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
			self.updateTodoCounter()
			self.setupProgressbarLayer()
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
	
	func updateTodoCounter() {
		self.taskCountLabel.text = "\(NSLocalizedString("Done", comment: "")): \(category.countDone()) / \(category.count())"
	}
	
	//MARK: Appearance
	
	func setupProgressbarLayer() {
		if self.layer.sublayers != nil && self.layer.sublayers!.count > 1 {
			guard let oldLayer = self.layer.sublayers?.first else {
				return
			}
			self.layer.replaceSublayer(oldLayer, with: createProgressbarLayer())
		} else {
			self.layer.insertSublayer(createProgressbarLayer(), at: 0)
		}
	}
	
	private func createProgressbarLayer() -> CALayer {
		let done = category.countDone()
		let loadedPercentage: CGFloat = done == 0 ? 0 : CGFloat(done) / CGFloat(category.count())
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = self.bounds
		gradientLayer.colors = [UIColor(red: 0.349, green: 0.9176, blue: 0, alpha: 0.7).cgColor, UIColor.white.cgColor]
		if loadedPercentage == 0 || loadedPercentage == 1 {
			// Completely fill progressbar
			gradientLayer.locations = [loadedPercentage, loadedPercentage] as [NSNumber]
		} else {
			// Smoothen transition
			gradientLayer.locations = [max(0, loadedPercentage - 0.15), loadedPercentage] as [NSNumber]
		}
		
		gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
		return gradientLayer
	}
	
	
	
}
