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
	
	//MARK: Properties
	var created: Date
	var id: String
	var deadline: Date?
	var alarm: Date?
	var done: Date?
	var title: String
	var cellHeight: CGFloat?
	
	struct PropertyKeys {
		static let created = "created"
		static let id = "id"
		static let deadline = "deadline"
		static let alarm = "alarm"
		static let done = "done"
		static let title = "title"
		static let cellHeight = "cellHeight"
	}
	
	init(title: String) {
		self.created = Date()
		self.title = title
		self.id = Utils.generateID()
	}
	
	//TODO
	func getDueString() -> String {
		return ""
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
	
	//MARK: NSCoding
	
	func encode(with aCoder: NSCoder) {
		aCoder.encode(created, forKey: PropertyKeys.created)
		aCoder.encode(id, forKey: PropertyKeys.id)
		aCoder.encode(deadline, forKey: PropertyKeys.deadline)
		aCoder.encode(alarm, forKey: PropertyKeys.alarm)
		aCoder.encode(done, forKey: PropertyKeys.done)
		aCoder.encode(title, forKey: PropertyKeys.title)
		aCoder.encode(cellHeight, forKey: PropertyKeys.cellHeight)
	}
	
	required init?(coder aDecoder: NSCoder) {
		guard let created = aDecoder.decodeObject(forKey: PropertyKeys.created) as? Date,
			let id = aDecoder.decodeObject(forKey: PropertyKeys.id) as? String,
			let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String else {
				fatalError("Error loading Task from storage!")
		}
		self.created = created
		self.id = id
		self.title = title
		self.cellHeight = aDecoder.decodeObject(forKey: PropertyKeys.cellHeight) as? CGFloat
		self.deadline = aDecoder.decodeObject(forKey: PropertyKeys.deadline) as? Date
		self.alarm = aDecoder.decodeObject(forKey: PropertyKeys.alarm) as? Date
		self.done = aDecoder.decodeObject(forKey: PropertyKeys.done) as? Date
	}
}
