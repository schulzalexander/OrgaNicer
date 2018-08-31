//
//  SideMenuButton.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 31.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class SideMenuButton: UIButton {
	
	//MARK: Properties
	var xCenterActive: CGFloat!
	var xCenterHidden: CGFloat!
	var action: ((_ sender: UIButton) -> ())!
	
	init(frame: CGRect, title: NSAttributedString, color: UIColor, action: @escaping (_ sender: UIButton) -> ()) {
		super.init(frame: frame)
		
		self.action = action
		self.xCenterHidden = self.center.x
		self.xCenterActive = self.center.x - frame.width / 2
		
		setupAppearance(title: title, color: color)
		setupActions()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func show() {
		center.x = xCenterActive
	}
	
	func hide() {
		center.x = xCenterHidden
	}
	
	private func setupAppearance(title: NSAttributedString, color: UIColor) {
		setAttributedTitle(title, for: .normal)
		setTitleColor(UIColor.black, for: .normal)
		setTitleColor(UIColor.lightGray, for: .highlighted)
		contentHorizontalAlignment = .left
		backgroundColor = color
		
		layer.cornerRadius = frame.height / 2
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
		layer.shadowOpacity = 1.0
		layer.shadowRadius = 3.0
	}
	
	private func setupActions() {
		addTarget(self, action: #selector(self.buttonTouchUpInside), for: UIControl.Event.touchUpInside)
		addTarget(self, action: #selector(self.buttonTouchDown), for: UIControl.Event.touchDown)
		addTarget(self, action: #selector(self.buttonTouchUpOutside), for: UIControl.Event.touchUpOutside)
	}
	
	@objc private func buttonTouchDown(_ sender: UIButton) {
		sender.layer.shadowColor = UIColor.clear.cgColor
	}
	
	@objc private func buttonTouchUpOutside(_ sender: UIButton) {
		sender.layer.shadowColor = UIColor.black.cgColor
	}
	
	@objc private func buttonTouchUpInside(_ sender: UIButton) {
		action(sender)
		sender.layer.shadowColor = UIColor.black.cgColor
	}
	
}
