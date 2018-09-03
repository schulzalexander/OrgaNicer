//
//  OverlayDecisionView.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 18.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class OverlayDecisionView: UIView {
	
	enum CancelButtonPosition {
		case top, bottom, center
	}
	
	static let DEFAULT_CANCEL_HEIGHT: CGFloat = 90
	static let DEFAULT_CANCEL_COLOR = UIColor(red: 0.7882, green: 0.2667, blue: 0.2667, alpha: 1.0)
	static let DEFAULT_BUTTON_COLOR = UIColor(red: 0.1412, green: 0.7882, blue: 0.5294, alpha: 0.7)
	static let DEFAULT_BUTTON_BORDER_COLOR = UIColor(red: 0.1176, green: 0.6588, blue: 0.451, alpha: 1.0)
	
	var cancelButton: UIButton!
	var selectedCancelPosition: CancelButtonPosition!
	var presenter: UIViewController!
	var decisionButtons: [UIButton]!
	var decisionButtonInfo: [(String, ()->())]! // title: action
	
	init(presenter: UIViewController, cancelPosition: CancelButtonPosition) {
		super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
		self.presenter = presenter
		self.selectedCancelPosition = cancelPosition
		self.decisionButtonInfo = [(String, ()->())]()
		self.decisionButtons = [UIButton]()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func addOption(title: String, action: @escaping ()->()) {
		decisionButtonInfo.append((title, action))
	}
	
	//MARK: Setup Methods
	
	private func setupDecisionButtons() {
		let height = (selectedCancelPosition == .center
			? UIScreen.main.bounds.height
			: UIScreen.main.bounds.height - OverlayDecisionView.DEFAULT_CANCEL_HEIGHT)
			/ CGFloat(decisionButtonInfo.count)
		let width = UIScreen.main.bounds.width
		var currY = selectedCancelPosition == .top ? OverlayDecisionView.DEFAULT_CANCEL_HEIGHT : 0
		for i in 0..<decisionButtonInfo.count {
			let newButton = UIButton(frame: CGRect(x: 0, y: currY, width: width, height: height))
			let attrTitle = NSAttributedString(string: decisionButtonInfo[i].0, attributes: [NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 30)!,
																							 NSAttributedStringKey.foregroundColor: UIColor.white])
			newButton.setAttributedTitle(attrTitle, for: .normal)
			newButton.setTitleColor(UIColor.black, for: .normal)
			newButton.backgroundColor = OverlayDecisionView.DEFAULT_BUTTON_COLOR
			newButton.layer.borderColor = OverlayDecisionView.DEFAULT_BUTTON_BORDER_COLOR.cgColor
			newButton.layer.borderWidth = 5
			newButton.layer.cornerRadius = 30
			newButton.tag = i
			newButton.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
			self.addSubview(newButton)
			decisionButtons.append(newButton)
			currY += height + 1
		}
	}
	
	private func setupCancelButton() {
		var frame: CGRect
		var center: CGPoint
		var cornerRadius: CGFloat
		switch selectedCancelPosition! {
		case .bottom:
			frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 2 * OverlayDecisionView.DEFAULT_CANCEL_HEIGHT,
						   width: UIScreen.main.bounds.width, height: OverlayDecisionView.DEFAULT_CANCEL_HEIGHT)
			center = CGPoint(x: UIScreen.main.bounds.width / 2,
							 y: UIScreen.main.bounds.height - OverlayDecisionView.DEFAULT_CANCEL_HEIGHT)
			cornerRadius = 10
		case .top:
			frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: OverlayDecisionView.DEFAULT_CANCEL_HEIGHT)
			center = CGPoint(x: UIScreen.main.bounds.width / 2,
							 y: OverlayDecisionView.DEFAULT_CANCEL_HEIGHT)
			cornerRadius = 10
		case .center:
			frame = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2,
						   width: OverlayDecisionView.DEFAULT_CANCEL_HEIGHT, height: OverlayDecisionView.DEFAULT_CANCEL_HEIGHT)
			center = CGPoint(x: UIScreen.main.bounds.width / 2,
							 y: UIScreen.main.bounds.height / 2)
			cornerRadius = frame.height / 2
		}
		cancelButton = UIButton(frame: frame)
		cancelButton.center = center
		cancelButton.layer.cornerRadius = cornerRadius
		cancelButton.backgroundColor = OverlayDecisionView.DEFAULT_CANCEL_COLOR.withAlphaComponent(0.7)
		cancelButton.layer.borderWidth = 3
		cancelButton.layer.borderColor = OverlayDecisionView.DEFAULT_CANCEL_COLOR.cgColor
		let attrTitle = NSAttributedString(string: "×", attributes: [NSAttributedStringKey.font: UIFont(name: "AmericanTypewriter", size: 45)!,
																	  NSAttributedStringKey.foregroundColor: UIColor.white])
		cancelButton.setAttributedTitle(attrTitle, for: .normal)
		cancelButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
		self.addSubview(cancelButton)
	}
	
	//MARK: Button Events
	
	@objc func didPressButton(_ sender: UIButton) {
		decisionButtonInfo![sender.tag].1()
		dismiss()
	}
	
	@objc func dismiss() {
		self.removeFromSuperview()
	}
	
	//MARK: Presenting
	
	func show() {
		setupDecisionButtons()
		setupCancelButton()
		presenter.view.addSubview(self)
	}
	
}
