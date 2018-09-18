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
	var selectedTheme: Themes
	var firstAppStart: Bool
	
	static var shared = Settings()
	
	struct PropertyKeys {
		static let feedbackSendingDates = "feedbackSendingDates"
		static let selectedThemes = "selectedThemes"
		static let firstAppStart = "firstAppStart"
	}
	
	private override init() {
		feedbackSendingDates = [Date]()
		selectedTheme = .light
		firstAppStart = true
		super.init()
	}
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(feedbackSendingDates, forKey: PropertyKeys.feedbackSendingDates)
		aCoder.encode(selectedTheme.rawValue, forKey: PropertyKeys.selectedThemes)
		aCoder.encode(firstAppStart, forKey: PropertyKeys.firstAppStart)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let feedbackSendingDates = aDecoder.decodeObject(forKey: PropertyKeys.feedbackSendingDates) as? [Date],
			let selectedTheme = Themes(rawValue: aDecoder.decodeInteger(forKey: PropertyKeys.selectedThemes)) else {
			fatalError("Error while decoding Settings!")
		}
		self.feedbackSendingDates = feedbackSendingDates
		self.selectedTheme = selectedTheme
		self.firstAppStart = aDecoder.decodeBool(forKey: PropertyKeys.firstAppStart)
	}
	
	
	
	
}
