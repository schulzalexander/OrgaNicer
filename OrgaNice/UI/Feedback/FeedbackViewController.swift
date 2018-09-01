//
//  FeedbackViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 31.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class FeedbackViewController: UIViewController, UITextViewDelegate {
	
	//MARK: Outlets
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var sendButton: UIButton!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.largeTitleDisplayMode = .never
		
		textView.delegate = self
		textView.text = NSLocalizedString("FeedbackPlaceholder", comment: "")
		textView.textColor = UIColor.lightGray
		textView.layer.borderWidth = 1.0
		textView.layer.borderColor = UIColor.gray.cgColor
		textView.layer.cornerRadius = 10
		
		sendButton.backgroundColor = UIColor(red: 0, green: 0.6314, blue: 1, alpha: 1.0)
		sendButton.layer.cornerRadius = 20
		sendButton.layer.shadowColor = UIColor.black.cgColor
		sendButton.layer.shadowRadius = 1.0
		sendButton.layer.shadowOpacity = 1.0
		sendButton.layer.shadowOffset = CGSize(width: 0, height: 0)
		
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapOnView(_:)))
		self.view.addGestureRecognizer(gestureRecognizer)
		// Do any additional setup after loading the view.
	}
	
	@objc func tapOnView(_ sender: UIGestureRecognizer) {
		textView.resignFirstResponder()
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = ""
			textView.textColor = UIColor.black
		}
	}
	
	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
		let numberOfChars = newText.count // for Swift use count(newText)
		return numberOfChars < 500;
	}
	
	@IBAction func send(_ sender: UIButton) {
		if textView.text.count > 5000 {
			let alertController = UIAlertController(title: nil, message: NSLocalizedString("FeedbackTooLongMessage", comment: ""), preferredStyle: .alert)
			alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
			self.present(alertController, animated: true, completion: nil)
			return
		}
		if textView.text.count != 0 && textView.textColor != UIColor.lightGray {
			if !shouldSendFeedback() {
				// too many feedbacks were sent within the last hour
				print("User sent too many feedbacks already, canceling...")
				self.navigationController?.popViewController(animated: true)
				return
			}
			updateSendingDateSettings()
			
			let ref = Database.database().reference().child("Feedback")
			let key = ref.childByAutoId().key
			let post = ["value": textView.text]
			let childUpdates = ["/Feedback/\(key)": post]
			ref.updateChildValues(childUpdates) { (error, database) in
				guard error == nil else {
					print("Error during Feedback upload: \(error!.localizedDescription)")
					return
				}
			}
		}
		self.navigationController?.popViewController(animated: true)
	}
	
	private func shouldSendFeedback() -> Bool {
		let dates = Settings.shared.feedbackSendingDates
		if dates.count < 2 {
			return true
		} else {
			return dates[0] < Date().addingTimeInterval(-3600)
		}
	}
	
	private func updateSendingDateSettings() {
		// We save the dates of sent feedback to prevent flooding
		if Settings.shared.feedbackSendingDates.count >= 10 {
			Settings.shared.feedbackSendingDates.remove(at: 0)
		}
		Settings.shared.feedbackSendingDates.append(Date())
		SettingsArchive.save()
	}

}
