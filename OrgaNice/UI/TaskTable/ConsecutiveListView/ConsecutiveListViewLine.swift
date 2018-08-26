//
//  ConsecutiveListViewLine.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 26.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit


class ConsecutiveListViewLine: UIView {
	
	var task: Task! {
		didSet {
			self.titleTextField.text = task.title
		}
	}
	var titleTextField: UITextField!
	var arrowIndicatorLabel: UILabel!
	
	init(task: Task, frame: CGRect) {
		super.init(frame: frame)
		initSubviews(task: task)
		self.task = task
		self.layer.cornerRadius = 3
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initSubviews(task: nil)
	}
	
	private func initSubviews(task: Task?) {
		let contentHeight = self.frame.height * 0.8
		let label = UILabel(frame: CGRect(x: 10,
										  y: (self.frame.height - contentHeight) / 2,
										  width: contentHeight,
										  height: contentHeight))
		let textfield = UITextField(frame: CGRect(x: label.frame.maxX + 10,
												  y: 0,
												  width: self.frame.width - contentHeight - 30,
												  height: self.frame.height))
		textfield.text = task?.title // task will be nil at this point if empty line is initialized
		
		self.addSubview(textfield)
		self.addSubview(label)
		self.titleTextField = textfield
		self.arrowIndicatorLabel = label
		
	}
	
	func setLineCurrent(isCurrent: Bool) {
		// If this is the currently active task, add an arrow indicator, else rule out the title and remove the arrow
		setTitleScoredOut(isRuledOut: !isCurrent)
		setArrowIndicator(show: isCurrent)
	}
	
	private func setTitleScoredOut(isRuledOut: Bool) {
		let attributes = isRuledOut
			? [NSAttributedString.Key.strikethroughStyle: 2]
			: nil
		let attributedText = NSAttributedString(string: task.title,
												attributes: attributes)
		titleTextField.attributedText = attributedText
	}
	
	private func setArrowIndicator(show: Bool) {
		arrowIndicatorLabel.text = show ? "→" : nil
	}
	
}

