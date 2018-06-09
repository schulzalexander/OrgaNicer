//
//  OrgaNiceTests.swift
//  OrgaNiceTests
//
//  Created by Alexander Schulz on 04.06.18.
//  Copyright © 2018 Alexander Schulz. All rights reserved.
//

import XCTest
@testable import OrgaNice

class OrgaNiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	//MARK: TaskCategory
	func testTaskCategoryAdding() {
		let list = TaskCategory(title: "")
		let task1 = Task(title: "")
		let task2 = Task(title: "")
		let task3 = Task(title: "")
		list.addTask(task: task1)
		list.addTask(task: task2)
		list.addTask(task: task3)
		XCTAssert(list.count() == 3)
		list.deleteTask(id: task1.id)
		list.deleteTask(id: task2.id)
		list.deleteTask(id: task3.id)
	}
	
	func testTaskCategoryRemoving() {
		let list = TaskCategory(title: "")
		let task1 = Task(title: "")
		let task2 = Task(title: "")
		list.addTask(task: task1)
		list.addTask(task: task2)
		list.deleteTask(id: task1.id)
		XCTAssert(list.count() == 1)
		list.deleteTask(id: task2.id)
	}
	
	func testTaskCategoryCountDone() {
		let list = TaskCategory(title: "")
		let task1 = Task(title: "")
		let task2 = Task(title: "")
		let task3 = Task(title: "")
		list.addTask(task: task1)
		list.addTask(task: task2)
		list.addTask(task: task3)
		task1.setDone()
		task2.setDone()
		assert(list.countDone() == 2)
		assert(list.countUndone() == 1)
		list.deleteTask(id: task1.id)
		list.deleteTask(id: task2.id)
		list.deleteTask(id: task3.id)
	}
	
	//MARK: Task
	func testTaskInitsID() {
		let task = Task(title: "")
		assert(task.id.count > 0)
	}
	
	func testTaskDueString() {
		
	}
	
	func testTaskArchiving() {
		let task = Task(title: "")
		let url = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("Testing")
		NSKeyedArchiver.archiveRootObject(task, toFile: url.path)
		let savedTask = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? Task
		XCTAssert(savedTask != nil)
	}
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
