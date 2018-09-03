//
//  FilterBar.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 23.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class FilterBar: UIStackView {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor.lightGray.cgColor
		self.axis = .horizontal
		self.distribution = .fillEqually
		setupButtons()
	}
	
	private func setupButtons() {
		let b1 = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: self.frame.height))
		b1.setTitle("Servus", for: .normal)
		b1.setTitleColor(UIColor.black, for: .normal)
		self.addArrangedSubview(b1)
	}
	
}
