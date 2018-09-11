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
	@IBOutlet weak var imageView: UIImageView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setupImageView()
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		let customLayoutAttributes = layoutAttributes as! SelectorCollectionViewLayoutAttributes
		self.layer.anchorPoint = customLayoutAttributes.anchorPoint
		self.center.y += (customLayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
	}
	
	private func setupImageView() {
		self.imageView.frame.size.height = self.frame.height * 0.8 // leave space for shadow
		self.imageView.frame.size.width = self.imageView.frame.height
		self.imageView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
		self.imageView.center.x = UIScreen.main.bounds.width * 0.3
		self.imageView.center.y = self.frame.height / 2
		
		self.imageView.layer.shadowColor = UIColor.gray.cgColor
		self.imageView.layer.shadowRadius = 4.0
		self.imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
		self.imageView.layer.shadowOpacity = 1.0
		
		self.imageView.layer.cornerRadius = self.imageView.frame.size.height / 2
	}
	
}
