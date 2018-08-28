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
		//setupTransparentGradientBackground()
		setupTrapez()
	}
	
	func scrollToIndex(index: Int) {
		var offset: CGFloat = 0
		let categoryCount = CGFloat(self.numberOfItems(inSection: 0) - 1)
		if categoryCount > 0 {
			offset = (self.contentSize.width - self.bounds.width)
				/ categoryCount
				* CGFloat(index)
		}
		self.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
	}
	
	func getNearestIndex() -> Int {
		let offsetPerItem = (self.contentSize.width - self.bounds.width)
			/ CGFloat(self.numberOfItems(inSection: 0) - 1)
		let diff = self.contentOffset.x.truncatingRemainder(dividingBy: offsetPerItem)
		let index = Int((self.contentOffset.x - diff) / offsetPerItem)
		if diff < offsetPerItem / 2 {
			return index
		} else {
			return index + 1
		}
	}
	
	private func setupTransparentGradientBackground() {
		let colour:UIColor = .white//UIColor(red: 1, green: 0.5922, blue: 0.098, alpha: 0.5)
		let colours:[CGColor] = [colour.withAlphaComponent(0.0).cgColor,colour.cgColor]
		let locations:[NSNumber] = [0, 0.7]
		
		let backgrdView = UIView(frame: self.frame)
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = colours
		gradientLayer.locations = locations
		gradientLayer.frame = self.bounds
		
		backgrdView.layer.addSublayer(gradientLayer)
		self.backgroundView = backgrdView
	}
	
	private func setupTrapez() {
		let shape = CAShapeLayer()
		let backgrdView = UIView(frame: self.frame)
		backgrdView.layer.addSublayer(shape)
		self.backgroundView = backgrdView
		
		shape.opacity = 0.8
		shape.lineWidth = 2
		shape.lineJoin = CAShapeLayerLineJoin.miter
		shape.strokeColor = UIColor.black.cgColor
		shape.fillColor = UIColor.gray.cgColor
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: frame.height))
		path.addLine(to: CGPoint(x: 15, y: frame.height - 40))
		path.addLine(to: CGPoint(x: frame.width - 15, y: frame.height - 40))
		path.addLine(to: CGPoint(x: frame.width, y: frame.height))
		path.close()
		shape.path = path.cgPath
	}

}
