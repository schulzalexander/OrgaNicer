//
//  FilterBar.swift
//  OrgaNice
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
		
		setupButtons()
	}
	
	private func setupButtons() {
		
	}
	
}
