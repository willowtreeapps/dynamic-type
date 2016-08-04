//
//  SnapshotTests.swift
//  DynamicTypeExample
//
//  Created by Ian Terrell on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
@testable import DynamicTypeExample

class SnapshotTests: FBSnapshotTestCase {
    
    static var controller: ViewController!
    static var window: UIWindow!


    override class func setUp() {
        super.setUp()

        controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as! ViewController

        UIApplication.shared.keyWindow?.rootViewController = controller
        controller.loadViewIfNeeded()
        window = UIApplication.shared.keyWindow
    }

    override func setUp() {
        super.setUp()
        recordMode = false
    }

    func testDynamicFonts() {
        DynamicTypeSizeCategories.forEach { size in
            SnapshotTests.controller.updateFonts(preferredContentSize: size)
            FBSnapshotVerifyView(SnapshotTests.window, identifier: size.description)
        }
    }
}
