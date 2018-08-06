//
//  AlarmManager.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 06.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UserNotifications

class AlarmManager {
	
	static func addAlarm(task: Task, sound: Bool) {
		let content = UNMutableNotificationContent()
		content.body = task.title
		content.title = "Todo Reminder"
		content.sound = sound ? UNNotificationSound.default() : nil
		
		
	}
	
	static func removeAlarm(id: String) {
		
	}
	
}
