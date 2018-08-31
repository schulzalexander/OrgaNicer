//
//  SideMenu.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 31.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class SideMenu {
	
	//MARK: Properties
	var buttons: [(SideMenuButton, Bool)]! // (Button, AlwaysOn)
	var superview: UIView!
	var isHidden: Bool!
	
	init(superview: UIView) {
		self.buttons = [(SideMenuButton, Bool)]()
		self.superview = superview
		self.isHidden = true
	}
	
	func addButton(button: SideMenuButton, alwaysOn: Bool) {
		// Keep array sorted according to Y position
		var insertAt = 0
		for i in 0..<buttons.count {
			if buttons[i].0.frame.minY > button.frame.minY {
				insertAt = i
				break
			}
		}
		buttons.insert((button, alwaysOn), at: insertAt)
		superview.addSubview(button)
	}
	
	func show() {
		var delay: Double = 0
		for button in buttons {
			if button.1 {
				continue
			}
			UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseOut, animations: {
				button.0.show()
			}, completion: nil)
			delay += 0.1
		}
		isHidden = false
	}
	
	func hide() {
		var delay: Double = 0
		for button in buttons {
			if button.1 {
				continue
			}
			UIView.animate(withDuration: 0.2, delay: delay, options: .curveEaseOut, animations: {
				button.0.hide()
			}, completion: nil)
			delay += 0.1
		}
		isHidden = true
	}
	
	func toggle() {
		if isHidden {
			show()
		} else {
			hide()
		}
	}
	
}
