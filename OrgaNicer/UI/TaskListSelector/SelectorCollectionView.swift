//
//  SelectorCollectionView.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 16.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class SelectorCollectionView: UICollectionView {
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
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
	
	private func setupGradientBackground(frame: CGRect) -> CAGradientLayer {
		let colours:[CGColor] = Theme.categoryTrapezGradientColors
		let locations:[NSNumber] = [0, 1]
		let gradientLayer = CAGradientLayer()
		
		gradientLayer.colors = colours
		gradientLayer.locations = locations
		gradientLayer.frame = frame
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
		
		return gradientLayer
	}
	
	private func setupTrapez() {
		let height: CGFloat = 40, width: CGFloat = self.frame.width
		let frame = CGRect(x: 0, y: self.frame.height - height, width: width, height: height)
		let shape = CAShapeLayer()
		
		shape.opacity = 0.9
		shape.lineWidth = 2
		shape.backgroundColor = UIColor.clear.cgColor
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: frame.height))
		path.addLine(to: CGPoint(x: 15, y: frame.height - 40))
		path.addLine(to: CGPoint(x: frame.width - 15, y: frame.height - 40))
		path.addLine(to: CGPoint(x: frame.width, y: frame.height))
		path.close()
		shape.path = path.cgPath
		
		let gradientLayer = setupGradientBackground(frame: frame)
		gradientLayer.mask = shape
		let backgrdView = UIView(frame: self.frame)
		backgrdView.layer.addSublayer(gradientLayer)
		self.backgroundView = backgrdView
	}

}

extension SelectorCollectionView: ThemeDelegate {
	
	func updateAppearance() {
		setupTrapez()
		reloadData()
	}
	
}
