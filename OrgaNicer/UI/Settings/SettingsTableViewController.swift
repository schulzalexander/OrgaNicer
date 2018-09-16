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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 11.0, *) {
			self.navigationItem.largeTitleDisplayMode = .never
		}
		
		themeDarkCheckmarkLable.isHidden = !(Settings.shared.selectedTheme == .dark)
		themeLightCheckmarkLable.isHidden = !(Settings.shared.selectedTheme == .light)
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
			
			self.tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
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
			self.tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
		}
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
			self.tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
		}
		alertController.addAction(reset)
		alertController.addAction(cancel)
		present(alertController, animated: true, completion: nil)
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
		let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (action) in
			self.tableView.selectRow(at: nil, animated: true, scrollPosition: .none)
		}
		alertController.addAction(reset)
		alertController.addAction(cancel)
		present(alertController, animated: true, completion: nil)
	}
	
}
