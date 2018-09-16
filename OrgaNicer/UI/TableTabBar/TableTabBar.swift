//
//  TableTabBar.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 21.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class TableTabBar: UIView {
	
	//MARK: Constants
	let highlighterHeight: CGFloat = 3
	let highlighterWidthPerc: CGFloat = 0.6
	
	//MARK: Properties
	var highlighter: UIView!
	var currTab: Int?
	var tabs: [UIButton] = [UIButton]()
	var closures: [()->()] = [()->()]()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = Theme.tableTabBarBackgroundColor
		self.layer.opacity = 0.9
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func addTab(title: String, action: @escaping ()->()) {
		let button = UIButton(type: .custom)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
		button.setTitle(title, for: .normal)
		button.backgroundColor = UIColor.clear
		button.setTitleColor(Theme.tableTabBarFontColor, for: .normal)
		button.tag = self.tabs.count
		button.addTarget(self, action: #selector(TableTabBar.onTabPressed(_:)), for: .touchUpInside)
		
		self.addSubview(button)
		self.closures.append(action)
		self.tabs.append(button)
		
		let itemWidth = Int(self.frame.width) / self.tabs.count
		for i in 0..<self.tabs.count {
			self.tabs[i].frame = CGRect(x: itemWidth * i, y: 0, width: itemWidth, height: Int(self.frame.height))
		}
		
		if self.tabs.count == 1 {
			currTab = 0
			initHighlighter()
		} else {
			updateHighlighter()
		}
	}
	
	@objc func onTabPressed(_ sender: UIButton) {
		switchToTab(index: sender.tag)
	}
	
	func switchToTab(index: Int) {
		guard index < closures.count else {
			return
		}
		currTab = index
		closures[index]()
		
		updateHighlighter()
	}
	
	//MARK: Private Methods
	
	private func updateHighlighter() {
		guard currTab != nil else {
			return
		}
		let rect = getHighlighterRectForIndex(index: currTab!)
		let xDiff = rect.minX - highlighter.frame.minX
		highlighter.frame.size.width = rect.width
		UIView.animate(withDuration: 0.1) {
			self.highlighter.center.x += xDiff
		}
	}
	
	private func initHighlighter() {
		guard self.tabs.count > 0 else {
			return
		}
		highlighter = UIView(frame: getHighlighterRectForIndex(index: 0))
		highlighter.backgroundColor = Theme.tableTabBarFontColor
		highlighter.layer.cornerRadius = highlighterHeight / 2
		self.addSubview(highlighter)
		self.sendSubview(toBack: highlighter)
	}
	
	private func getHighlighterRectForIndex(index: Int) -> CGRect {
		let tabWidth = self.frame.width / CGFloat(self.tabs.count)
		let padding = tabWidth * (1 - highlighterWidthPerc) / 2
		return CGRect(x: tabWidth * CGFloat(index) + padding,
					  y: self.frame.height - highlighterHeight - 3,
					  width: tabWidth * highlighterWidthPerc,
					  height: highlighterHeight)
	}
}

extension TableTabBar: ThemeDelegate {
	
	func updateAppearance() {
		self.backgroundColor = Theme.tableTabBarBackgroundColor
		tabs.forEach { (button) in
			button.setTitleColor(Theme.tableTabBarFontColor, for: .normal)
		}
		highlighter.backgroundColor = Theme.tableTabBarFontColor
	}
	
}




















