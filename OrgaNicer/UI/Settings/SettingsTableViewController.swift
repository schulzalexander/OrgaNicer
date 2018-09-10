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
	@IBOutlet weak var resetButton: UIButton!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 11.0, *) {
			self.navigationItem.largeTitleDisplayMode = .never
		}
		
		setupResetButton()
    }
	
	@IBAction func resetContent(_ sender: UIButton) {
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
		present(alertController, animated: true, completion: nil)
	}
	
	private func setupResetButton() {
		resetButton.backgroundColor = UIColor.red
		resetButton.layer.cornerRadius = resetButton.frame.height / 2
		resetButton.clipsToBounds = true
	}
	
}
