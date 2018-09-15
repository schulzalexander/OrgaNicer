//
//  SelectorCollectionViewCell.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 03.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class SelectorCollectionViewCell: UICollectionViewCell {
	
	//MARK: Properties
	var category: TaskCategory! {
		didSet {
			guard category != nil else {
				return
			}
			self.titleLabel.text = category!.title
			self.updateContent()
			priorityGradientView.frame = getPriorityGradientFrame()
		}
	}
	
	//MARK: Outlets
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var taskCountLabel: UILabel!
	
	var progressbarView: ProgressbarView!
	var priorityGradientView: PriorityGradientView!
	var viewContainer: UIView! // Insert custom views as subviews of this container, else layout changes during swipe will do strange things
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		viewContainer = UIView(frame: self.bounds)
		viewContainer.backgroundColor = UIColor.purple
		insertSubview(viewContainer, at: 0)
		
		initPriorityGradient()
		initProgressbar()
		
		self.backgroundColor = UIColor.white
		self.layer.masksToBounds = false
		self.layer.shadowColor = UIColor.gray.cgColor
		self.layer.shadowRadius = 5.0
		self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
		self.layer.shadowOpacity = 1.0
	}
	
	override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
		super.apply(layoutAttributes)
		let customLayoutAttributes = layoutAttributes as! SelectorCollectionViewLayoutAttributes
		self.layer.anchorPoint = customLayoutAttributes.anchorPoint
		self.center.y += (customLayoutAttributes.anchorPoint.y - 0.5) * self.bounds.height
		viewContainer.frame = self.bounds
		progressbarView.frame = getProgressbarFrame()
		priorityGradientView.frame = getPriorityGradientFrame()
	}
	
	//MARK: Content Setup
	
	func updateContent() {
		updateTodoCounter()
		updatePriorityGradient()
		updateProgressbar()
	}
	
	private func updateTodoCounter() {
		self.taskCountLabel.text = "\(NSLocalizedString("Done", comment: "")): \(category.countDone()) / \(category.count())"
	}
	
	//MARK: PriorityGradient
	
	private func initPriorityGradient() {
		priorityGradientView = PriorityGradientView(frame: getPriorityGradientFrame(), taskPriority: calcAvergeTaskPriority())
		viewContainer.addSubview(priorityGradientView)
	}
	
	private func updatePriorityGradient() {
		priorityGradientView.updatePriority(priority: calcAvergeTaskPriority())
	}
	
	private func getPriorityGradientFrame() -> CGRect {
		return viewContainer.bounds
	}
	
	private func calcAvergeTaskPriority() -> CGFloat? {
		guard category != nil else {
			return nil
		}
		return category.getAverageTaskPriority()
	}
	
	
	//MARK: ProgressBar
	
	private func initProgressbar() {
		progressbarView = ProgressbarView(frame: getProgressbarFrame(), loadedPercentage: calcProgressbarPercentage())
		progressbarView.layer.cornerRadius = 4.0
		progressbarView.clipsToBounds = true
		viewContainer.addSubview(progressbarView)
	}
	
	private func updateProgressbar() {
		progressbarView.updatePercentage(loadedPercentage: calcProgressbarPercentage() ?? 0)
	}
	
	private func getProgressbarFrame() -> CGRect {
		return CGRect(x: viewContainer.frame.width * 0.1,
					  y: taskCountLabel.frame.minY,
					  width: viewContainer.frame.width * 0.8,
					  height: taskCountLabel.frame.height)
	}
	
	private func calcProgressbarPercentage() -> CGFloat? {
		guard category != nil else {
			return nil
		}
		let done = category.countDone()
		return done == 0 ? 0 : CGFloat(done) / CGFloat(category.count())
	}
	
}









