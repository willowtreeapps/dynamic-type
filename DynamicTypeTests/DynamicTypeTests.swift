//
//  DynamicTypeTests.swift
//  DynamicTypeTests
//
//  Created by Ian Terrell on 8/11/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
@testable import DynamicType

class FontMapTests: XCTestCase {
    enum MyStyle {
        case awesome
        case rad
    }

    let map = FontMap<MyStyle> { style, category in
        switch (style, category) {
        case (_, UIContentSizeCategory.small):
            return UIFont(name: "Helvetica", size: 10)!
        case (.awesome, _):
            return UIFont(name: "Helvetica", size: 20)!
        case (.rad, _):
            return UIFont(name: "Helvetica", size: 30)!
        }
    }

    func testStyle() {
        let awesome = map.font(style: .awesome, sizeCategory: .accessibilityExtraExtraLarge)
        XCTAssertEqual(20, awesome.pointSize)

        let rad = map.font(style: .rad, sizeCategory: .accessibilityExtraExtraLarge)
        XCTAssertEqual(30, rad.pointSize)
    }

    func testSizeCategory() {
        let rad = map.font(style: .rad, sizeCategory: .small)
        XCTAssertEqual(10, rad.pointSize)
    }
}

class DefaultFontMapTests: XCTestCase {
    let map = UIFontTextStyle.defaultFontMap

    func testBody() {
        let font = map.font(style: .body, sizeCategory: .accessibilityExtraExtraLarge)
        let pointSize = UIFontTextStyle.body.defaultFontPointSize(sizeCategory: .accessibilityExtraExtraLarge)
        XCTAssertEqual(pointSize, font.pointSize)

        let defaultfont = UIFont.systemFont(ofSize: pointSize)
        XCTAssertEqual(defaultfont.fontName, font.fontName)
    }

    func testBoldHeadline() {
        let font = map.font(style: .headline, sizeCategory: .medium)
        let pointSize = UIFontTextStyle.headline.defaultFontPointSize(sizeCategory: .medium)
        XCTAssertEqual(pointSize, font.pointSize)

        let defaultfont = UIFont.boldSystemFont(ofSize: pointSize)
        XCTAssertEqual(defaultfont.fontName, font.fontName)
    }
}

class SwizzleTests: XCTestCase {
    class MyViewController: UIViewController, RespondsToDynamicFont {
        var lastSize: UIContentSizeCategory?
        func updateFonts(preferredContentSize: UIContentSizeCategory) {
            lastSize = preferredContentSize
        }
    }

    override class func setUp() {
        UIViewController.swizzleDynamicTypeViewDidLoad()
    }

    func testNotification() {
        func notification(_ size: UIContentSizeCategory) -> Notification {
            return Notification(name: .UIContentSizeCategoryDidChange,
                                object: nil,
                                userInfo: [UIContentSizeCategoryNewValueKey: size])
        }

        let vc = MyViewController()
        vc.viewDidLoad()
        XCTAssertNil(vc.lastSize)
        NotificationCenter.default.post(notification(.small))
        XCTAssertEqual(UIContentSizeCategory.small, vc.lastSize)
        NotificationCenter.default.post(notification(.medium))
        XCTAssertEqual(UIContentSizeCategory.medium, vc.lastSize)
    }
}




