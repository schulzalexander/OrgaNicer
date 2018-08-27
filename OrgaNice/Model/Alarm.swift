//
//  Alarm.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 07.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class Alarm: Deadline {
	
	//MARK: Properties
	var sound: Bool
	
	struct PropertyKeys {
		static let sound = "sound"
	}
	
	init(id: String, date: Date, frequency: Frequency, category: String?, sound: Bool) {
		self.sound = sound
		super.init(id: id, date: date, frequency: frequency, category: category)
	}
	
	init(deadline: Deadline, sound: Bool) {
		self.sound = sound
		super.init(id: deadline.id, date: deadline.date, frequency: deadline.frequency, category: deadline.category)
	}
	
	//MARK: NSCoding
	
	override func encode(with aCoder: NSCoder) {
		aCoder.encode(sound, forKey: PropertyKeys.sound)
		super.encode(with: aCoder)
	}
	
	required init?(coder aDecoder: NSCoder) {
		sound = aDecoder.decodeBool(forKey: PropertyKeys.sound)
		super.init(coder: aDecoder)
	}
	
}
