//
//  ProgressbarLayer.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 11.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class ProgressbarLayer: CAGradientLayer {
	
	var loadedPercentage: CGFloat!
	
	override var frame: CGRect {
		didSet {
			setupAppearance()
		}
	}
	
	init(loadedPercentage: CGFloat) {
		self.loadedPercentage = loadedPercentage
		
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func setupAppearance() {
		self.colors = [UIColor(red: 0.349, green: 0.9176, blue: 0, alpha: 0.7).cgColor, UIColor.clear.cgColor]
		if loadedPercentage == 0 || loadedPercentage == 1 {
			// Completely fill progressbar
			self.locations = [loadedPercentage, loadedPercentage] as [NSNumber]
		} else {
			// Smoothen transition
			self.locations = [max(0, loadedPercentage - 0.15), loadedPercentage] as [NSNumber]
		}
		
		self.startPoint = CGPoint(x: 0, y: 0.5)
		self.endPoint = CGPoint(x: 1, y: 0.5)
	}
	
}
