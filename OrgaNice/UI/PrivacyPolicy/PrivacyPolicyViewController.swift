//
//  PrivacyPolicyViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 31.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class PrivacyPolicyViewController: UIViewController {
	
	@IBOutlet weak var textView: UITextView!
	
	override func viewDidLoad() {
		self.navigationItem.largeTitleDisplayMode = .never
		do {
			let at : NSAttributedString = try NSAttributedString(data: NSLocalizedString("PrivacyPolicy", comment: "").data(using: .unicode)!, options:
				[NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil);
			textView.attributedText = at;
		} catch {
			textView.text = NSLocalizedString("PrivacyPolicy", comment: "");
		}
	}
	
}
