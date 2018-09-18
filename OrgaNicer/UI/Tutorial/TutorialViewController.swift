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
	var explanationLabel: UITextView!
	
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
		layoutExplanationLabel()
		updateContent(content: content)
    }
	
	private func updateContent(content: TutorialPage) {
		imageView.image = content.image
		explanationLabel.text = content.explanation
	}
	
	//MARK: Layout Subviews
	
	private func layoutImageView() {
		let width: CGFloat = 0.7 * UIScreen.main.bounds.width
		let height: CGFloat = 0.7 * UIScreen.main.bounds.height
		let frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: 50, width: width, height: height)
		imageView = UIImageView(frame: frame)
		view.addSubview(imageView)
		
		imageView.layer.shadowColor = UIColor.gray.cgColor
		imageView.layer.shadowRadius = 8
		imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
		imageView.layer.shadowOpacity = 1.0
	}
	
	private func layoutExplanationLabel() {
		let width: CGFloat = 0.7 * UIScreen.main.bounds.width
		let height: CGFloat = 0.15 * UIScreen.main.bounds.height
		let frame = CGRect(x: (UIScreen.main.bounds.width - width) / 2, y: imageView.frame.maxY + 20, width: width, height: height)
		explanationLabel = UITextView(frame: frame)
		view.addSubview(explanationLabel)
		explanationLabel.backgroundColor = nil
		explanationLabel.font = UIFont.systemFont(ofSize: 18)
		explanationLabel.widthAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
		explanationLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true
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
