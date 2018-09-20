//
//  TutorialViewController.swift
//  OrgaNicer
//
//  Created by Alexander Schulz on 18.09.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

	//MARK: Properties
	var content: TutorialPage!
	var imageView: UIImageView!
	var titleLabel: UILabel!
	var explanationTextView: UITextView!
	
	init(content: TutorialPage) {
		self.content = content
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		view.backgroundColor = .white
		setupGradientBackground()
		layoutImageView()
		layoutTitleLable()
		layoutExplanationLabel()
		updateContent(content: content)
    }
	
	private func updateContent(content: TutorialPage) {
		imageView.image = content.image
		titleLabel.text = content.title
		explanationTextView.text = content.explanation
	}
	
	//MARK: Layout Subviews
	
	private func layoutImageView() {
		let width: CGFloat = 0.6 * UIScreen.main.bounds.width
		let height: CGFloat = 1920 / 1080 * width
		let frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: (UIScreen.main.bounds.height - height) / 5 * 2, width: width, height: height)
		imageView = UIImageView(frame: frame)
		view.addSubview(imageView)
		imageView.layer.shadowColor = UIColor.gray.cgColor
		imageView.layer.shadowRadius = 8
		imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
		imageView.layer.shadowOpacity = 1.0
	}
	
	private func layoutTitleLable() {
		let width: CGFloat = 0.8 * UIScreen.main.bounds.width
		let height: CGFloat = 30
		let frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: imageView.frame.minY - 45, width: width, height: height)
		titleLabel = UILabel(frame: frame)
		titleLabel.font = UIFont(name: "Helvetica-Bold", size: 24)
		view.addSubview(titleLabel)
	}
	
	private func layoutExplanationLabel() {
		let width: CGFloat = 0.8 * UIScreen.main.bounds.width
		let height: CGFloat = UIScreen.main.bounds.height - imageView.frame.maxY - 55 // Prevent it from overlapping the Page Dots
		let frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: imageView.frame.maxY + (UIScreen.main.bounds.height - imageView.frame.maxY - height) / 2, width: width, height: height)
		explanationTextView = UITextView(frame: frame)
		view.addSubview(explanationTextView)
		explanationTextView.backgroundColor = nil
		explanationTextView.font = UIFont.systemFont(ofSize: 18)
		explanationTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50).isActive = true
	}
	
	private func setupGradientBackground() {
		let colours:[CGColor] = [UIColor.lightGray.withAlphaComponent(0.2).cgColor, UIColor.white.cgColor]
		let locations:[NSNumber] = [0, 0.6]
		
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = colours
		gradientLayer.locations = locations
		gradientLayer.startPoint = CGPoint(x: 0, y: 0)
		gradientLayer.endPoint = CGPoint(x: 1, y: 1)
		gradientLayer.frame = self.view.bounds
		
		view.layer.addSublayer(gradientLayer)
	}

}
