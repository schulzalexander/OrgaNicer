//
//  TaskTableDisplayable.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 19.08.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import Foundation
import UIKit

protocol TaskTableDisplayable {
	
	func createTaskExtensionView(frame: CGRect) -> TaskTableViewCellContent?
	
	func getTaskExtensionHeight() -> CGFloat
	
}
