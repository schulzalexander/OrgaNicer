//
//  SettingsViewController.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 09.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

	//MARK: Outlets
	@IBOutlet weak var themeLightCheckmarkLable: UILabel!
	@IBOutlet weak var themeDarkCheckmarkLable: UILabel!
	@IBOutlet weak var darkThemeIndicator: UIView!
	@IBOutlet weak var lightThemeIndicator: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 11.0, *) {
			self.navigationItem.largeTitleDisplayMode = .never
		}
		
		themeDarkCheckmarkLable.isHidden = !(Settings.shared.selectedTheme == .dark)
		themeLightCheckmarkLable.isHidden = !(Settings.shared.selectedTheme == .light)
		setupThemeIndicators()
		
		updateAppearance()
    }
	
	//MARK: UITableViewDelegate
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			// Themes
			if indexPath.row == 0 {
				// Light
				Settings.shared.selectedTheme = .light
			}
			if indexPath.row == 1 {
				// Dark
				Settings.shared.selectedTheme = .dark
			}
			SettingsArchive.save()
			
			themeDarkCheckmarkLable.isHidden = !(Settings.shared.selectedTheme == .dark)
			themeLightCheckmarkLable.isHidden = !(Settings.shared.selectedTheme == .light)
			
			navigationController?.viewControllers.forEach({ (viewController) in
				guard let themeDelegate = viewController as? ThemeDelegate else {
					return
				}
				themeDelegate.updateAppearance()
			})
			(navigationController as? ThemeDelegate)?.updateAppearance()
		}
		if indexPath.section == 1 {
			// Reset
			if indexPath.row == 0 {
				// Alarm Reset
				resetAlarms()
			}
			if indexPath.row == 1 {
				// Complete Content Reset
				resetContent()
			}
		}
		if indexPath.section == 2 {
			// Replay Tutorial
			if indexPath.row == 0 {
				guard self.storyboard != nil else {
					return
				}
				let viewController = self.storyboard!.instantiateViewController(withIdentifier: "TutorialPageViewController")
				DispatchQueue.main.async {
					self.present(viewController, animated: true, completion: nil)
				}
			}
			
			// Rate App
			if indexPath.row == 1 {
				rateApp()
			}
			
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.selectionStyle = .none
		cell.backgroundColor = Theme.settingsTableViewCellBackgroundColor
	}
	
	//MARK: Themes
	
	private func setupThemeIndicators() {
		for view: UIView in [lightThemeIndicator, darkThemeIndicator] {
			view.layer.cornerRadius = view.frame.width / 2
			view.layer.borderColor = UIColor.lightGray.cgColor
			view.layer.borderWidth = 1.0
			view.clipsToBounds = true
		}
	}
	
	//MARK: Content Reset
	
	private func resetAlarms() {
		let alertController = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("AlarmResetAlertMessage", comment: ""), preferredStyle: .alert)
		let reset = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (action) in
			AlarmManager.removeAllAlarms()
			TaskManager.shared.tasks.forEach({ (key, val) in
				if let mainTask = val as? MainTask {
					mainTask.alarm = nil
					TaskArchive.saveTask(task: mainTask)
				}
			})
			self.navigationController?.popToRootViewController(animated: true)
		}
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(reset)
		alertController.addAction(cancel)
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	private func resetContent() {
		let alertController = UIAlertController(title: NSLocalizedString("Attention", comment: ""), message: NSLocalizedString("ContentResetAlertMessage", comment: ""), preferredStyle: .alert)
		let reset = UIAlertAction(title: NSLocalizedString("Reset", comment: ""), style: .destructive) { (action) in
			guard let taskTable = self.navigationController?.viewControllers.first as? TaskTableViewController else {
				return
			}
			TaskCategoryManager.shared.deleteAllTaskCategories()
			AlarmManager.removeAllAlarms()
			taskTable.currList = nil
			taskTable.updateTaskOrdering()
			taskTable.tableView.reloadData()
			taskTable.categorySelector.reloadData()
			taskTable.categorySelector.scrollToIndex(index: 0)
			taskTable.navigationItem.title = nil
			self.navigationController?.popToRootViewController(animated: true)
		}
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
		alertController.addAction(reset)
		alertController.addAction(cancel)
		DispatchQueue.main.async {
			self.present(alertController, animated: true, completion: nil)
		}
	}
	
	//MARK: Other section
	
	private func rateApp() {
		guard let url = URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1435006104?mt=8"),
			UIApplication.shared.canOpenURL(url) else {
			return
		}
		UIApplication.shared.open(url, options: [:], completionHandler: nil)
	}
	
	
}

extension SettingsTableViewController: ThemeDelegate {
	
	func updateAppearance() {
		tableView.backgroundColor = Theme.settingsTableViewBackgroundColor
		tableView.separatorColor = Theme.settingsTableViewSeperatorColor
		tableView.reloadData()
	}
	
}






