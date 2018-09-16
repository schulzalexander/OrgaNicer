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

class Theme {
	static var navigationBarTintColor: UIColor? {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return nil
			case .dark:
				return UIColor.gray
			}
		}
	}
	
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
	
	static var progressbarColor: CGColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor(red: 0.349, green: 0.9176, blue: 0, alpha: 0.7).cgColor
			case .dark:
				return UIColor(red: 0, green: 0.6784, blue: 0.4078, alpha: 1.0).cgColor
			}
		}
	}
	
	static var settingsBackgroundColor: CGColor {
		get {
			switch Settings.shared.selectedTheme {
			case .light:
				return UIColor(red: 0.349, green: 0.9176, blue: 0, alpha: 0.7).cgColor
			case .dark:
				return UIColor(red: 0, green: 0.6784, blue: 0.4078, alpha: 1.0).cgColor
			}
		}
	}
}

protocol ThemeDelegate {
	func updateAppearance()
}
