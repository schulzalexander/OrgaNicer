//
//  Themes.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 16.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

enum Themes: Int {
	case light, dark
}

protocol ThemeDelegate {
	func updateAppearance()
}

class Theme {
	
	// MARK: Navigation Controller
	static var navigationBarTintColor: UIColor? {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return nil
			case .dark:
				return UIColor.darkGray
			}
		}
	}
	
	//MARK: Category Selector
	static var categoryCellBackgroundColor: CGColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor.white.cgColor
			case .dark:
				return UIColor.white.withAlphaComponent(0.5).cgColor
			}
		}
	}
	
	static var progressbarColor: CGColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor(red: 0.349, green: 0.9176, blue: 0, alpha: 0.7).cgColor
			case .dark:
				return UIColor(red: 0.3529, green: 0.9373, blue: 0.2902, alpha: 1.0).cgColor
			}
		}
	}
	
	static var categoryTrapezGradientColors: [CGColor] {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return [UIColor.gray.cgColor,UIColor.white.cgColor]
			case .dark:
				return [UIColor.black.cgColor, UIColor.lightGray.cgColor]
			}
		}
	}
	
	//MARK: TaskTable
	static var mainBackgroundGradientColors: [CGColor] {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return [UIColor.lightGray.withAlphaComponent(0.1).cgColor, UIColor.white.cgColor]
			case .dark:
				return [UIColor.darkGray.cgColor, UIColor.lightGray.cgColor]
			}
		}
	}
	
	static var tableTabBarBackgroundColor: UIColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return .white
			case .dark:
				return UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
			}
		}
	}
	
	static var tableTabBarFontColor: UIColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return .lightGray
			case .dark:
				return .white
			}
		}
	}
	
	static var taskCellSeperatorColor: UIColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return .white
			case .dark:
				return .black
			}
		}
	}
	
	static var taskCellShadowColor: CGColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor.gray.cgColor
			case .dark:
				return UIColor.black.cgColor
			}
		}
	}
	
	//MARK: Settings
	static var settingsTableViewBackgroundColor: UIColor? {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor(red: 0.937255, green: 0.937255, blue: 0.956863, alpha: 1)
			case .dark:
				return UIColor.lightGray
			}
		}
	}
	
	static var settingsTableViewCellBackgroundColor: UIColor? {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor.white
			case .dark:
				return UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)//UIColor.lightGray.withAlphaComponent(0.4)
			}
		}
	}
	
	static var settingsTableViewSeperatorColor: UIColor? {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return nil
			case .dark:
				return UIColor.black
			}
		}
	}
	
}


















