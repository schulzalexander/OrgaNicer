//
//  AlarmManager.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 06.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UserNotifications

class AlarmManager {
	
	static func addAlarm(task: Task, alarm: Alarm) {
		let content = UNMutableNotificationContent()
		content.body = task.title
		content.title = TaskCategoryManager.shared.getTaskCategory(id: alarm.category ?? "")?.title
			?? NSLocalizedString("TodoReminder", comment: "")
		content.sound = alarm.sound ? UNNotificationSound.default : nil
		
		var attributes: Set<Calendar.Component> = [.hour, .minute]
		if alarm.frequency == .unique {
			attributes.insert(.day)
		} else if alarm.frequency == .weekly {
			attributes.insert(.weekday)
		}
		let dateComponents = NSCalendar.current.dateComponents(attributes, from: alarm.date)
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: alarm.frequency != .unique)
		let request = UNNotificationRequest(identifier: alarm.id, content: content, trigger: trigger)
		
		UNUserNotificationCenter.current().add(request) { (error) in
			guard error == nil else {
				print("Error during task reminder notification: \(error!.localizedDescription).")
				return
			}
		}
	}
	
	static func removeAlarm(id: String) {
		UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
	}
	
}
