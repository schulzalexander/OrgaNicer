//
//  SelectorCollectionView.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 16.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class SelectorCollectionView: UICollectionView {
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		setupTransparentGradientBackground()
	}
	
	func scrollToIndex(index: Int) {
		let offset = (self.contentSize.width - self.bounds.width)
			/ CGFloat(self.numberOfItems(inSection: 0) - 1)
			* CGFloat(index)
		self.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
	}
	
	private func setupTransparentGradientBackground() {
		let colour:UIColor = .white
		let colours:[CGColor] = [colour.withAlphaComponent(0.0).cgColor,colour.cgColor]
		let locations:[NSNumber] = [0, 0.2]
		
		let backgrdView = UIView(frame: self.frame)
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = colours
		gradientLayer.locations = locations
		gradientLayer.frame = self.bounds
		
		backgrdView.layer.addSublayer(gradientLayer)
		self.backgroundView = backgrdView
	}

}
