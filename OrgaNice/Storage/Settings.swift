//
//  Settings.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 22.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation

class Settings {
	
	static let SETTINGSDIR: String = "Settings"
	
	struct Keys {
	}
	
	static func settingDir(key: String) -> URL {
		guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			fatalError("Failed to retrieve task archive URL!")
		}
		return url.appendingPathComponent(SETTINGSDIR).appendingPathComponent(key)
	}
	
	static func save(key: String, object: Any) {
		let success = NSKeyedArchiver.archiveRootObject(object, toFile: settingDir(key: key).path)
		if !success {
			fatalError("Error while saving setting \(key)!")
		}
	}
	
	static func load(key: String) -> Any? {
		return NSKeyedUnarchiver.unarchiveObject(withFile: settingDir(key: key).path)
	}
	
}
