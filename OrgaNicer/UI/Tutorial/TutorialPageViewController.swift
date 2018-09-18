//
//  TutorialPageViewController.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 18.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TutorialPageViewController: UIPageViewController {

	var controllers: [UIViewController]!
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		for view in self.view.subviews {
			
			if view is UIScrollView {
				view.frame = UIScreen.main.bounds
			} else if view is UIPageControl {
				view.backgroundColor = UIColor.clear
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
		
		let contents = [
			TutorialPage(explanation: "Test explanation blablablablbalba", image: UIImage(named: "TaskListBackground") ?? UIImage()),
			TutorialPage(explanation: "Test explanation blablablab igu iu iug iug iug iugiugiug iug iug iug iug iu giuh oioihoihoih oih oih lbalba", image: UIImage(named: "TaskListBackground") ?? UIImage()),
			TutorialPage(explanation: "Test explanation blablablablbalba", image: UIImage(named: "TaskListBackground") ?? UIImage())
		]
		controllers = [UIViewController]()
		for content in contents {
//			guard let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController\(i)") else {
//				fatalError("Error while instantiating tutorial view controller!")
//			}
			let newController = TutorialViewController(content: content)
			controllers.append(newController)
		}
		
		setViewControllers([controllers[0]], direction: .forward, animated: true, completion: nil)
		layoutContinueButton()

		setupDotAppearance()
		if !Settings.shared.firstAppStart {
			setupCancelButton()
		}
    }

	
	private func setupDotAppearance() {
		//dots setup
		let appearance = UIPageControl.appearance()
		appearance.pageIndicatorTintColor = UIColor.lightGray
		appearance.currentPageIndicatorTintColor = UIColor.black
		appearance.backgroundColor = UIColor.clear
		
		appearance.layer.position.x = self.view.center.x
		appearance.layer.position.y = self.view.center.y
	}
	
	private func setupCancelButton() {
		let dim: CGFloat = 50 // Cancel Button dimension
		let buttonFrame = CGRect(x: view.frame.maxX - dim, y: 20, width: dim, height: dim)
		let button = UIButton(frame: buttonFrame)
		button.setTitle("×", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.titleLabel?.font = button.titleLabel?.font.withSize(40)
		button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		self.view.insertSubview(button, aboveSubview: self.view)
	}
	
	@objc private func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
	private func layoutContinueButton() {
		let width: CGFloat = 0.4 * UIScreen.main.bounds.width
		let height: CGFloat = 40
		let frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: UIScreen.main.bounds.height - 100, width: width, height: height)
		let button = UIButton(frame: frame)
		button.setTitle("Continue", for: .normal)
		button.backgroundColor = UIColor(red: 1, green: 0.7882, blue: 0.4, alpha: 1.0)
		button.layer.cornerRadius = button.frame.height / 2
		button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
		
		if let last = controllers.last {
			last.view.addSubview(button)
		}
	}

}


//MARK: PageViewControllerDataSource
extension TutorialPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let index = controllers.index(of: viewController) else {
			return nil
		}
		
		let prevIndex = index-1
		guard prevIndex < controllers.count else {
			return nil
		}
		
		guard prevIndex >= 0 else {
			return controllers.last
		}
		
		return controllers[prevIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let index = controllers.index(of: viewController) else {
			return nil
		}
		
		let nextIndex = index+1
		guard nextIndex >= 0 else {
			return nil
		}
		
		guard nextIndex < controllers.count else {
			return controllers.first
		}
		
		return controllers[nextIndex]
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return controllers.count
	}
	
	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		guard let firstViewController = viewControllers?.first,
			let index = controllers.index(of: firstViewController) else {
				return 0
		}
		return index
	}
	
	
}
