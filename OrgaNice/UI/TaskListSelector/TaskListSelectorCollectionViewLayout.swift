//
//  TaskListSelectorCollectionViewLayout.swift
//  TaskMaster
//
//  Created by Alexander Schulz on 02.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//
//  https://www.raywenderlich.com/107687/uicollectionview-custom-layout-tutorial-spinning-wheel

import UIKit

class TaskListSelectorCollectionViewLayout: UICollectionViewLayout {

	//MARK: Properties
	let itemSize = CGSize(width: 180, height: 150)
	var angleAtExtreme: CGFloat {
		return collectionView!.numberOfItems(inSection: 0) > 0 ?
			-CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem : 0
	}
	var angle: CGFloat {
		return angleAtExtreme * collectionView!.contentOffset.x / (collectionViewContentSize.width -
			self.collectionView!.bounds.width)
	}
	var radius: CGFloat = 500 {
		didSet {
			invalidateLayout()
		}
	}
	var anglePerItem: CGFloat {
		return atan(itemSize.width / radius)
	}
	var attributesList = [TaskListSelectorCollectionViewLayoutAttributes]()
	
	override var collectionViewContentSize: CGSize {
		return CGSize(width: CGFloat(self.collectionView!.numberOfItems(inSection: 0)) * itemSize.width,
					  height: self.collectionView!.bounds.height)
	}
	
	override class var layoutAttributesClass: AnyClass {
		return TaskListSelectorCollectionViewLayoutAttributes.self
	}
	
	override func prepare() {
		super.prepare()
		let centerX = collectionView!.contentOffset.x + (self.collectionView!.bounds.width / 2.0)
		let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
		let theta = atan2(self.collectionView!.bounds.width / 2.0, radius + (itemSize.height / 2.0) - (self.collectionView!.bounds.height / 2.0))
		var startIndex = 0
		var endIndex = collectionView!.numberOfItems(inSection: 0) - 1
		if (angle < -theta) {
			startIndex = Int(floor((-theta - angle) / anglePerItem))
		}
		endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
		if (endIndex < startIndex) {
			attributesList = []
		} else {
			attributesList = (startIndex...endIndex).map { (i) -> TaskListSelectorCollectionViewLayoutAttributes in
				let attributes = TaskListSelectorCollectionViewLayoutAttributes(forCellWith: IndexPath(item: i, section: 0))
				attributes.size = self.itemSize
				attributes.center = CGPoint(x: centerX, y: self.collectionView!.bounds.midY)
				attributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
				attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
				return attributes
			}
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		return attributesList
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return attributesList[indexPath.row]
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
}


