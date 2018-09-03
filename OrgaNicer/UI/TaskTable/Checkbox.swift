//
//  Checkbox.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 25.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class Checkbox: UIButton {
	
	var checked: Bool!
	var onCheckCompletionHandler: ((Bool) -> ())?
	
	init(frame: CGRect, onCheck: @escaping (Bool) -> ()) {
		super.init(frame: frame)
		
		self.checked = false
		self.onCheckCompletionHandler = onCheck
		self.layoutCheckbox()
		self.titleLabel?.adjustsFontSizeToFitWidth = true
		self.addTarget(self, action: #selector(check), for: .touchUpInside)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	@objc func check() {
		checked = !checked
		setChecked(checked: checked)
		
		guard onCheckCompletionHandler != nil else {
			return
		}
		onCheckCompletionHandler!(checked)
	}
	
	func setChecked(checked: Bool) {
		self.setTitle(checked ? "✔️" : nil, for: .normal)
	}
	
	private func layoutCheckbox() {
		backgroundColor = UIColor.white
		layer.cornerRadius = 5
		layer.borderColor = UIColor.black.cgColor
		layer.borderWidth = 1
	}
	
}
