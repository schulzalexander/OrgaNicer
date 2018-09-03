//
//  Settings.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 01.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class Settings: NSObject, NSCoding {
	
	//MARK: Properties
	var feedbackSendingDates: [Date]
	
	static var shared = Settings()
	
	struct PropertyKeys {
		static let feedbackSendingDates = "feedbackSendingDates"
	}
	
	private override init() {
		feedbackSendingDates = [Date]()
		super.init()
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(feedbackSendingDates, forKey: PropertyKeys.feedbackSendingDates)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let feedbackSendingDates = aDecoder.decodeObject(forKey: PropertyKeys.feedbackSendingDates) as? [Date] else {
			fatalError("Error while decoding Settings!")
		}
		self.feedbackSendingDates = feedbackSendingDates
	}
	
	
	
	
}
