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
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAddButton()
		
		self.navigationBar.backgroundColor = UIColor(red: 1, green: 0.5922, blue: 0.098, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	private func setupAddButton() {
		//setup addButton
		addButton = UIButton(type: .custom)
		let title = NSAttributedString(string: "  +", attributes: [NSAttributedStringKey.font: UIFont(name: "AmericanTypewriter", size: 45)!])
		addButton.setAttributedTitle(title, for: .normal)
		addButton.setTitleColor(UIColor.black, for: .normal)
		addButton.setTitleColor(UIColor.lightGray, for: .highlighted)
		addButton.contentHorizontalAlignment = .left
		addButton.frame = CGRect(x: 0, y: 0, width: 150, height: 60)
		addButton.backgroundColor = UIColor(red: 1, green: 0.9098, blue: 0.1098, alpha: 1.0)//UIColor(red: 1, green: 0.9529, blue: 0.3176, alpha: 1.0)
		//self.addGradient(view: addButton)
		//addButton.layer.borderColor = UIColor.lightgray.cgColor
		//addButton.layer.borderWidth = 1.0
		self.view.insertSubview(addButton, aboveSubview: self.view)
		
		addButton.center = CGPoint(x: self.view.frame.width, y: self.view.frame.height - 120 - (self.addButton.frame.height / 2))
		if UIScreen.main.nativeBounds.height == 2436 {
			//iPhone X
			addButton.center = CGPoint(x: self.view.frame.width - 30 - (self.addButton.frame.width / 2), y: self.view.frame.height - 160 - (self.addButton.frame.height / 2))
		}
		//addButton.clipsToBounds = true
		addButton.layer.cornerRadius = addButton.frame.height / 2
		addButton.layer.shadowColor = UIColor.black.cgColor
		addButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
		addButton.layer.shadowOpacity = 1.0
		addButton.layer.shadowRadius = 3.0
		addButton.addTarget(self, action: #selector(self.buttonTouchUpInside), for: UIControlEvents.touchUpInside)
		addButton.addTarget(self, action: #selector(self.buttonTouchDown), for: UIControlEvents.touchDown)
		addButton.addTarget(self, action: #selector(self.buttonTouchUpOutside), for: UIControlEvents.touchUpOutside)
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
