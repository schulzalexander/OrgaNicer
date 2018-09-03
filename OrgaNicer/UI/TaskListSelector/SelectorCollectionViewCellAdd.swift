//
//  SelectorCollectionViewCellAdd.swift
//  OrgaNicer
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
		setupLabel()
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		let customLayoutAttributes = layoutAttributes as! SelectorCollectionViewLayoutAttributes
		self.layer.anchorPoint = customLayoutAttributes.anchorPoint
		self.center.y += (customLayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
	}
	
	private func setupLabel() {
		self.addLabel.text = NSLocalizedString("CategorySelectorAddList", comment: "")
		self.addLabel.sizeToFit()
		
		self.addLabel.frame.size.width += 30
		self.addLabel.frame.size.height = self.addLabel.frame.size.width
		self.addLabel.center.x = UIScreen.main.bounds.width * 0.3
		self.addLabel.center.y = self.addLabel.frame.height / 2
		
		self.addLabel.layer.shadowColor = UIColor.gray.cgColor
		self.addLabel.layer.shadowRadius = 5.0
		self.addLabel.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
		self.addLabel.layer.shadowOpacity = 1.0
	}
	
}
