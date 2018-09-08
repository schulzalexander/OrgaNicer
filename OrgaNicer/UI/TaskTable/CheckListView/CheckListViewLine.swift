//
//  CheckListViewLine.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 25.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit


class CheckListViewLine: UIView, UIGestureRecognizerDelegate {
	
	var task: Task! {
		didSet {
			self.titleTextField.text = task.title
		}
	}
	var titleTextField: UITextField!
	var checkButton: UIButton!
	
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
	
	// Called when user is editing this line, and taps outside the keyboard
	@objc func stopEditingSubtask(_ sender: UITapGestureRecognizer) {
		guard let checklist = self.superview as? CheckListView else {
			return
		}
		titleTextField.resignFirstResponder()
		checklist.saveSubTask(titleTextField)
	}
	
	private func initSubviews(task: Task?) {
		let contentHeight = self.frame.height * 0.8
		let textfield = UITextField(frame: CGRect(x: 10,
												  y: 0,
												  width: self.frame.width - contentHeight - 30,
												  height: self.frame.height))
		textfield.text = task?.title // task will be nil at this point if empty line is initialized
		textfield.isEnabled = false
		let buttonFrame = CGRect(x: textfield.frame.maxX + 10,
								 y: (self.frame.height - contentHeight) / 2,
								 width: contentHeight,
								 height: contentHeight)
		let button = Checkbox(frame: buttonFrame) { (checked) in
			if checked {
				self.task.setDone()
			} else {
				self.task.setUndone()
			}
			TaskArchive.saveTask(task: self.task)
		}
		button.setChecked(checked: task?.done != nil)
		
		self.addSubview(textfield)
		self.addSubview(button)
		self.titleTextField = textfield
		self.checkButton = button
		
	}
	
}
