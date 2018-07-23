//
//  TaskCategorySettingsViewController.swift
//  OrgaNice
//
//  Created by Alexander Schulz on 22.07.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TaskCategorySettingsViewController: UIViewController {

	//MARK: Properties
	var category: TaskCategory!
	
	//MARK: Outlets
	@IBOutlet weak var categoryHeaderLabel: UILabel!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryHeaderLabel.text = category.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func cancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
