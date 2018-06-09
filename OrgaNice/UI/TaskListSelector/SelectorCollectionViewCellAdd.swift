//
//  SelectorCollectionViewCellAdd.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 09.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class SelectorCollectionViewCellAdd: UICollectionViewCell {
	
	//MARK: Outlets
	@IBOutlet weak var addLabel: UILabel!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.layer.borderColor = UIColor.lightGray.cgColor
		self.layer.borderWidth = 1.0
		self.layer.cornerRadius = 15

		//TODO: make border dashed
		// https://stackoverflow.com/questions/13679923/dashed-line-border-around-uiview
		
		//self.createGradientLayer(view: self)
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
