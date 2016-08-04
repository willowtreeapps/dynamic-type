//
//  ViewController.swift
//  DynamicTypeExample
//
//  Created by Ian Terrell on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

let fontMap = TextStyle.defaultFontMap

class ViewController: UIViewController, RespondsToDynamicFont {

    @IBOutlet var title1: UILabel!
    @IBOutlet var title2: UILabel!
    @IBOutlet var title3: UILabel!
    @IBOutlet var headline: UILabel!
    @IBOutlet var subhead: UILabel!
    @IBOutlet var body: UILabel!
    @IBOutlet var callout: UILabel!
    @IBOutlet var caption1: UILabel!
    @IBOutlet var caption2: UILabel!
    @IBOutlet var footnote: UILabel!

    func updateFonts(preferredContentSize: UIContentSizeCategory) {
        title1.font = fontMap.font(style: .title1, sizeCategory: preferredContentSize)
        title2.font = fontMap.font(style: .title2, sizeCategory: preferredContentSize)
        title3.font = fontMap.font(style: .title3, sizeCategory: preferredContentSize)
        headline.font = fontMap.font(style: .headline, sizeCategory: preferredContentSize)
        subhead.font = fontMap.font(style: .subheadline, sizeCategory: preferredContentSize)
        body.font = fontMap.font(style: .body, sizeCategory: preferredContentSize)
        callout.font = fontMap.font(style: .callout, sizeCategory: preferredContentSize)
        caption1.font = fontMap.font(style: .caption1, sizeCategory: preferredContentSize)
        caption2.font = fontMap.font(style: .caption2, sizeCategory: preferredContentSize)
        footnote.font = fontMap.font(style: .footnote, sizeCategory: preferredContentSize)
    }
}
