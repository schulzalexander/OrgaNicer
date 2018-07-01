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
			self.titleLabel.text = category.title
			self.taskCountLabel.text = "ToDo: \(category.countUndone())"
		}
	}
	
	//MARK: Outlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var taskCountLabel: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		//self.createGradientLayer(view: self)
		
		self.backgroundColor = UIColor.white
		//self.layer.borderColor = UIColor.black.cgColor
		//self.layer.borderWidth = 1.0
		self.layer.masksToBounds = false
		self.layer.cornerRadius = 15
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
	
	func createGradientLayer(view: UIView) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame = view.bounds
		gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
		gradientLayer.locations = [0, 1]
		view.layer.sublayers!.insert(gradientLayer, at: 0)
		//view.layer.sublayers![1].zPosition = 0
	}
	
}
