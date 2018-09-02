//
//  TaskTableNavigationController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 04.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskTableNavigationController: UINavigationController {

	//MARK: Properties
	var addButton: UIButton!
	var sideMenu: SideMenu!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setupSideMenu()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	private func setupSideMenu() {
		sideMenu = SideMenu(superview: view)
		let frameTemp = CGRect(x: view.frame.maxX + 5, // +5 for shadow
			y: view.frame.height - (UIScreen.main.nativeBounds.height == 2436 ? 220 : 190),
						   width: 150,
						   height: 60)
		
		let addFrame = CGRect(x: frameTemp.minX, y: frameTemp.minY, width: frameTemp.width, height: frameTemp.height)
		let addButton = SideMenuButton(frame: addFrame, title: NSAttributedString(string: "  +", attributes: [NSAttributedString.Key.font: UIFont(name: "Times", size: 45)!]), image: nil, color: Utils.getTaskCellColor(priority: Task.PRIORITY_MIN)) { (sender) in
			guard let taskTable = self.viewControllers.first as? TaskTableViewController else {
				return
			}
			taskTable.newTask()
		}
		sideMenu.addButton(button: addButton, alwaysOn: true)
		
		let feedbackFrame = CGRect(x: frameTemp.minX, y: frameTemp.minY - 80, width: frameTemp.width, height: frameTemp.height)
		let feedbackButton = SideMenuButton(frame: feedbackFrame, title: nil, image: UIImage(named: "ChatBubble"), color: Utils.getTaskCellColor(priority: Task.PRIORITY_MIN + 20)) { (sender) in
			if !(self.topViewController is FeedbackViewController) {
				self.sideMenu.hide(hideStatic: true)
				self.performSegue(withIdentifier: "TaskTableToFeedback", sender: nil)
			}
			//let controller = self.storyboard!.instantiateViewController(withIdentifier: "FeedbackViewController")
			//self.present(controller, animated: true, completion: nil)
		}
		sideMenu.addButton(button: feedbackButton, alwaysOn: false)
		
		let priPolFrame = CGRect(x: frameTemp.minX, y: frameTemp.minY - 160, width: frameTemp.width, height: frameTemp.height)
		let priPolButton = SideMenuButton(frame: priPolFrame, title: NSAttributedString(string: "  ?", attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 45)!]), image: nil, color: Utils.getTaskCellColor(priority: Task.PRIORITY_MIN + 40)) { (sender) in
			if !(self.topViewController is PrivacyPolicyViewController) {
				self.sideMenu.hide(hideStatic: true)
				self.performSegue(withIdentifier: "TaskTableToPrivacyPolicy", sender: self)
			}
			//let controller = self.storyboard!.instantiateViewController(withIdentifier: "PrivacyPolicyViewController")
			//self.present(controller, animated: true, completion: nil)
		}
		sideMenu.addButton(button: priPolButton, alwaysOn: false)
	}
	
	@objc private func buttonTouchDown(_ sender: UIButton) {
		sender.layer.shadowColor = UIColor.clear.cgColor
	}
	
	@objc private func buttonTouchUpOutside(_ sender: UIButton) {
		addButton.layer.shadowColor = UIColor.black.cgColor
	}
	
	@objc private func buttonTouchUpInside(_ sender: UIButton) {
		guard let taskTable = self.viewControllers.first as? TaskTableViewController else {
			return
		}
		addButton.layer.shadowColor = UIColor.black.cgColor
		taskTable.newTask()
	}

}
