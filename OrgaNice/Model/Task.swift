//
//  Task.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 31.05.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

class Task: NSObject, NSCoding {
	
	static let PRIORITY_MAX: CGFloat = 150
	static let PRIORITY_MIN: CGFloat = 70
	static let DEFAULT_CELL_HEIGHT: CGFloat = 70
	
	//MARK: Properties
	var created: Date
	var id: String
	var deadline: Deadline?
	var done: Date?
	var title: String
	var cellHeight: CGFloat
	var alarms: [Alarm]?
	
	struct PropertyKeys {
		static let created = "created"
		static let id = "id"
		static let deadline = "deadline"
		static let alarms = "alarms"
		static let done = "done"
		static let title = "title"
		static let cellHeight = "cellHeight"
	}
	
	init(title: String) {
		self.created = Date()
		self.title = title
		self.id = Utils.generateID()
		self.cellHeight = Task.DEFAULT_CELL_HEIGHT
	}
	
	func isDone() -> Bool {
		return done != nil
	}
	
	func setDone() {
		self.done = Date()
	}
	
	func setUndone() {
		self.done = nil
	}
	
	func hasAlarmSet(for alarmID: String) -> Bool {
		guard alarms != nil else {
			return false
		}
		for alarm in alarms! {
			if alarm.id == alarmID {
				return true
			}
		}
		return false
	}
	
	func addAlarm(alarm: Alarm) {
		if alarms == nil {
			alarms = [alarm]
		} else {
			alarms!.append(alarm)
		}
		AlarmManager.addAlarm(task: self, alarm: alarm)
	}
	
	func removeAlarm(alarmID: String) {
		for i in 0..<(alarms?.count ?? 0) {
			if alarms![i].id == alarmID {
				alarms!.remove(at: i)
				break
			}
		}
	}
	
	func getAlarm(id: String) -> Alarm? {
		guard alarms != nil else {
			return nil
		}
		for alarm in alarms! {
			if alarm.id == id {
				return alarm
			}
		}
		return nil
	}
	
	func hasAlarms() -> Bool {
		return alarms != nil && alarms!.count > 0
	}
	
	func resetAlarm(alarmID: String) {
		guard let alarm = getAlarm(id: alarmID) else {
			return
		}
		removeAlarm(alarmID: alarmID)
		addAlarm(alarm: alarm)
	}
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(created, forKey: PropertyKeys.created)
		aCoder.encode(id, forKey: PropertyKeys.id)
		aCoder.encode(deadline, forKey: PropertyKeys.deadline)
		aCoder.encode(alarms, forKey: PropertyKeys.alarms)
		aCoder.encode(done, forKey: PropertyKeys.done)
		aCoder.encode(title, forKey: PropertyKeys.title)
		aCoder.encode(cellHeight, forKey: PropertyKeys.cellHeight)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let created = aDecoder.decodeObject(forKey: PropertyKeys.created) as? Date,
			let id = aDecoder.decodeObject(forKey: PropertyKeys.id) as? String,
			let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String,
			let cellHeight = aDecoder.decodeObject(forKey: PropertyKeys.cellHeight) as? CGFloat else {
				fatalError("Error loading Task from storage!")
		}
		self.created = created
		self.id = id
		self.title = title
		self.cellHeight = cellHeight
		self.deadline = aDecoder.decodeObject(forKey: PropertyKeys.deadline) as? Deadline
		self.alarms = aDecoder.decodeObject(forKey: PropertyKeys.alarms) as? [Alarm]
		self.done = aDecoder.decodeObject(forKey: PropertyKeys.done) as? Date
	}
	
	//MARK: Static functions returning cell attributes depending on current priority
	static func getPriorityCellHeight(priority: CGFloat) -> CGFloat {
		return min(Task.PRIORITY_MAX, max(priority, Task.PRIORITY_MIN))
	}
	
	static func getPriorityFontColor(priority: CGFloat) -> UIColor {
		let percentage = (priority - Task.PRIORITY_MIN) / (Task.PRIORITY_MAX - Task.PRIORITY_MIN)
		let revPercentage = 1.0 - percentage
		let startColor = CIColor.black
		let endColor = CIColor.white
		let newR = (percentage * endColor.red
			+ revPercentage * startColor.red)
		let newG = (percentage * endColor.green
			+ revPercentage * startColor.green)
		let newB = (percentage * endColor.blue
			+ revPercentage * startColor.blue)
		return UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
	}
	
	static func getPriorityColor(priority: CGFloat) -> UIColor {
		var percentage = (priority - Task.PRIORITY_MIN) / (Task.PRIORITY_MAX - Task.PRIORITY_MIN)
		var resColor: UIColor
		
		let lowColor = CIColor(red: 1, green: 0.9098, blue: 0.1098, alpha: 1.0)
		let middleColor = CIColor(red: 1, green: 0.1098, blue: 0.1098, alpha: 1.0)
		let highColor = CIColor(red: 0.6078, green: 0, blue: 0, alpha: 1.0)
		
		if percentage > 0.5 {
			percentage = (percentage - 0.5) * 2
			let revPercentage = 1.0 - percentage
			let newR = (percentage * highColor.red
				+ revPercentage * middleColor.red)
			let newG = (percentage * highColor.green
				+ revPercentage * middleColor.green)
			let newB = (percentage * highColor.blue
				+ revPercentage * middleColor.blue)
			resColor = UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
		} else {
			percentage *= 2
			let revPercentage = 1.0 - percentage
			let newR = (revPercentage * lowColor.red
				+ percentage * middleColor.red)
			let newG = (revPercentage * lowColor.green
				+ percentage * middleColor.green)
			let newB = (revPercentage * lowColor.blue
				+ percentage * middleColor.blue)
			resColor = UIColor(red: newR, green: newG, blue: newB, alpha: 1.0)
		}
		
		return resColor
	}
	
	static func getPriorityTextSize(priority: CGFloat) -> CGFloat {
		return 18 + (priority - Task.PRIORITY_MIN) / (Task.PRIORITY_MAX - Task.PRIORITY_MIN) * 30
	}
}
















