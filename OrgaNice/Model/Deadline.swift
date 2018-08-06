//
//  Deadline.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 06.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class Deadline: NSObject, NSCoding {
	
	enum Frequency: Int {
		case unique, daily, weekly
	}
	
	//MARK: Properties
	var date: Date
	var frequency: Frequency
	
	struct PropertyKeys {
		static let date = "date"
		static let frequency = "frequency"
	}
	
	init(date: Date, frequency: Frequency) {
		self.date = date
		self.frequency = frequency
	}
	
	func getDueString() -> String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .full
		formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
		formatter.maximumUnitCount = 2
		
		/*
		let diff = self.deadline!.timeIntervalSinceNow
		let minutes = Int(diff / 60)
		let hours = Int(diff / 3600)
		let days = Int(diff / (3600 * 24))
		let weeks = Int(days / 7)
		
		if weeks >= 4 {
		formatter.maximumUnitCount = 2
		} else if days >= 2 {
		formatter.maximumUnitCount = 1
		} else if hours >= 1 {
		formatter.maximumUnitCount = 2
		} else if minutes >= 1 {
		formatter.maximumUnitCount = 1
		} else {
		formatter.maximumUnitCount = 1
		}
		*/
		
		let now = Date()
		let timeString = formatter.string(from: now, to: getNextDeadlineDate())
		var res = ""
		if timeString != nil {
			res = self.date < now
				? String(format: NSLocalizedString("DeadlinePast", comment: ""), timeString!.suffix(timeString!.count-1) as CVarArg)
				: String(format: NSLocalizedString("DeadlineFuture", comment: ""), timeString!)
		}
		return res
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(date, forKey: PropertyKeys.date)
		aCoder.encode(frequency.rawValue, forKey: PropertyKeys.frequency)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let date = aDecoder.decodeObject(forKey: PropertyKeys.date) as? Date,
			let frequency = Frequency(rawValue: aDecoder.decodeInteger(forKey: PropertyKeys.frequency)) else {
			fatalError("Error while decoding deadline object!")
		}
		self.date = date
		self.frequency = frequency
	}
	
	//MARK: Private Methods
	
	private func getNextDeadlineDate() -> Date {
		let now = Date()
		var nextDeadline = self.date
		if self.frequency != .unique {
			let pastMidnight = now.timeIntervalSince1970 / (3600 * 24)
			let dayTime = nextDeadline.timeIntervalSince1970.truncatingRemainder(dividingBy: 3600 * 24)
			
			if self.frequency == .daily {
				// Create Date with current day, but time taken from the stored deadline
				
				nextDeadline = Date(timeIntervalSince1970: pastMidnight + dayTime)
				// if the time has already in the past, the next deadline will be on the next day
				if nextDeadline < now {
					nextDeadline.addTimeInterval(3600 * 24)
				}
			} else if self.frequency == .weekly {
				let deadlineWeekday = Calendar.current.component(.weekday, from: nextDeadline)
				let dayTime = nextDeadline.timeIntervalSince1970.truncatingRemainder(dividingBy: 3600 * 24)
				// Special case: deadline is today
				if deadlineWeekday == Calendar.current.component(.weekday, from: now) {
					nextDeadline = Date(timeIntervalSince1970: pastMidnight + dayTime)
					// Check if deadline has already passed
					if nextDeadline < now {
						nextDeadline.addTimeInterval(3600 * 24)
					}
				} else {
					for i in 1..<7 {
						let otherDate = now.addingTimeInterval(TimeInterval(i * 3600 * 24))
						let otherWeekday = Calendar.current.component(.weekday, from: otherDate)
						if deadlineWeekday == otherWeekday {
							let weekdayMidnight = otherDate.timeIntervalSince1970 -
								otherDate.timeIntervalSince1970.truncatingRemainder(dividingBy: TimeInterval(i * 3600 * 24))
							nextDeadline = Date(timeIntervalSince1970: weekdayMidnight + dayTime)
						}
					}
				}
			}
		}
		return nextDeadline
	}
	
	
}













