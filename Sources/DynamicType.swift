//
//  DynamicType.swift
//  DynamicTypeExample
//
//  Created by Ian Terrell on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

/// FontMap will create and cache fonts for a given style and size category.
public final class FontMap<Style: Hashable> {
    let creator: (_ style: Style, _ sizeCategory: UIContentSizeCategory) -> UIFont
    var cache: [Style: [UIContentSizeCategory:UIFont]] = [:]

    public init(creator: @escaping (_ style: Style, _ sizeCategory: UIContentSizeCategory) -> UIFont) {
        self.creator = creator
    }

    public func font(style: Style, sizeCategory: UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory) -> UIFont {
        if let font = cache[style]?[sizeCategory] {
            return font
        }

        let font = creator(style, sizeCategory)
        cache[style] = cache[style] ?? [:]
        cache[style]?[sizeCategory] = font
        return font
    }
}

extension UIFont.TextStyle {
    /// A default font map for default styles
    public static let defaultFontMap = FontMap<UIFont.TextStyle>(creator: defaultFontMapping)
}

@objc public protocol RespondsToDynamicFont {
    func updateFonts(preferredContentSize: UIContentSizeCategory)
}

extension UIViewController {
    static let swizzle: Void = {
        UIViewController.dynamicType_swizzleMethod(#selector(UIViewController.viewDidLoad),
                                                   swizzled: #selector(UIViewController.dynamicType_viewDidLoad))
    }()

    public class func swizzleDynamicTypeViewDidLoad() {
        _ = swizzle
    }

    @objc func dynamicType_viewDidLoad() {
        dynamicType_viewDidLoad()
        dynamicType_initializeFonts()
        NotificationCenter.default.addObserver(self,
                                               selector: .updateFonts,
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)

    }

    func dynamicType_initializeFonts() {
        guard let responder = self as? RespondsToDynamicFont else {
            return
        }

        responder.updateFonts(preferredContentSize: UIApplication.shared.preferredContentSizeCategory)
    }

    @objc func dynamicType_updateFonts(notification: Notification) {
        guard let responder = self as? RespondsToDynamicFont,
              let preference = notification.userInfo?[UIContentSizeCategory.newValueUserInfoKey] as? UIContentSizeCategory
        else {
            return
        }

        responder.updateFonts(preferredContentSize: preference)
    }
    
    static func dynamicType_swizzleMethod(_ original: Selector, swizzled: Selector) {
        guard let originalMethod = class_getInstanceMethod(self, original),
            let swizzledMethod = class_getInstanceMethod(self, swizzled) else {
                return
        }
        
        let didAddMethod = class_addMethod(self, original, method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(self, swizzled, method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}

extension Selector {
    static let updateFonts = #selector(UIViewController.dynamicType_updateFonts(notification:))
}

/// All size categories for easy iteration
public let sizeCategories: [UIContentSizeCategory] = [
    .extraSmall,
    .small,
    .medium,
    .large,
    .extraLarge,
    .extraExtraLarge,
    .extraExtraExtraLarge,
    .accessibilityMedium,
    .accessibilityLarge,
    .accessibilityExtraLarge,
    .accessibilityExtraExtraLarge,
    .accessibilityExtraExtraExtraLarge,
]

extension UIContentSizeCategory: CustomStringConvertible {
    public var description: String {
        switch self {
        case UIContentSizeCategory.extraSmall:                        return "00-extraSmall"
        case UIContentSizeCategory.small:                             return "01-small"
        case UIContentSizeCategory.medium:                            return "02-medium"
        case UIContentSizeCategory.large:                             return "03-large-DEFAULT"
        case UIContentSizeCategory.extraLarge:                        return "04-extraLarge"
        case UIContentSizeCategory.extraExtraLarge:                   return "05-extraExtraLarge"
        case UIContentSizeCategory.extraExtraExtraLarge:              return "06-extraExtraExtraLarge"
        case UIContentSizeCategory.accessibilityMedium:               return "07-accessibilityMedium"
        case UIContentSizeCategory.accessibilityLarge:                return "08-accessibilityLarge"
        case UIContentSizeCategory.accessibilityExtraLarge:           return "09-accessibilityExtraLarge"
        case UIContentSizeCategory.accessibilityExtraExtraLarge:      return "10-accessibilityExtraExtraLarge"
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return "11-accessibilityExtraExtraExtraLarge"
        default:                                                      return "12-unspecified"
        }
    }
}

extension UIFont.TextStyle {
    public static func defaultFontMapping(style: UIFont.TextStyle,
                                          sizeCategory: UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory) -> UIFont {
        return style.defaultFontMapping(sizeCategory: sizeCategory)
    }

    /// The iOS default font for a given size category.
    public func defaultFontMapping(sizeCategory: UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory) -> UIFont {
        let pointSize = defaultFontPointSize(sizeCategory: sizeCategory)

        switch self {
        case UIFont.TextStyle.headline:
            return .boldSystemFont(ofSize: pointSize)
        default:
            return .systemFont(ofSize: pointSize)
        }
    }
}

extension UIFont.TextStyle {
    /// The iOS defaults for font sizes for a given style and size category.
    public func defaultFontPointSize(sizeCategory: UIContentSizeCategory = UIApplication.shared.preferredContentSizeCategory) -> CGFloat {
        switch (self, sizeCategory) {
        case (UIFont.TextStyle.title1, UIContentSizeCategory.extraSmall):                        return 25
        case (UIFont.TextStyle.title1, UIContentSizeCategory.small):                             return 26
        case (UIFont.TextStyle.title1, UIContentSizeCategory.medium):                            return 27
        case (UIFont.TextStyle.title1, UIContentSizeCategory.large):                             return 28
        case (UIFont.TextStyle.title1, UIContentSizeCategory.extraLarge):                        return 30
        case (UIFont.TextStyle.title1, UIContentSizeCategory.extraExtraLarge):                   return 32
        case (UIFont.TextStyle.title1, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.title1, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.title1, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.title1, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.title1, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.title1, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 34

        case (UIFont.TextStyle.title2, UIContentSizeCategory.extraSmall):                        return 19
        case (UIFont.TextStyle.title2, UIContentSizeCategory.small):                             return 20
        case (UIFont.TextStyle.title2, UIContentSizeCategory.medium):                            return 21
        case (UIFont.TextStyle.title2, UIContentSizeCategory.large):                             return 22
        case (UIFont.TextStyle.title2, UIContentSizeCategory.extraLarge):                        return 24
        case (UIFont.TextStyle.title2, UIContentSizeCategory.extraExtraLarge):                   return 26
        case (UIFont.TextStyle.title2, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.title2, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.title2, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.title2, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.title2, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.title2, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 28

        case (UIFont.TextStyle.title3, UIContentSizeCategory.extraSmall):                        return 17
        case (UIFont.TextStyle.title3, UIContentSizeCategory.small):                             return 18
        case (UIFont.TextStyle.title3, UIContentSizeCategory.medium):                            return 19
        case (UIFont.TextStyle.title3, UIContentSizeCategory.large):                             return 20
        case (UIFont.TextStyle.title3, UIContentSizeCategory.extraLarge):                        return 22
        case (UIFont.TextStyle.title3, UIContentSizeCategory.extraExtraLarge):                   return 24
        case (UIFont.TextStyle.title3, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.title3, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.title3, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.title3, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.title3, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.title3, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 26

        case (UIFont.TextStyle.headline, UIContentSizeCategory.extraSmall):                        return 14
        case (UIFont.TextStyle.headline, UIContentSizeCategory.small):                             return 15
        case (UIFont.TextStyle.headline, UIContentSizeCategory.medium):                            return 16
        case (UIFont.TextStyle.headline, UIContentSizeCategory.large):                             return 17
        case (UIFont.TextStyle.headline, UIContentSizeCategory.extraLarge):                        return 19
        case (UIFont.TextStyle.headline, UIContentSizeCategory.extraExtraLarge):                   return 21
        case (UIFont.TextStyle.headline, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.headline, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.headline, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.headline, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.headline, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.headline, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 23

        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.extraSmall):                        return 12
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.small):                             return 13
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.medium):                            return 14
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.large):                             return 15
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.extraLarge):                        return 17
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.extraExtraLarge):                   return 19
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.subheadline, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 21

        case (UIFont.TextStyle.body, UIContentSizeCategory.extraSmall):                        return 14
        case (UIFont.TextStyle.body, UIContentSizeCategory.small):                             return 15
        case (UIFont.TextStyle.body, UIContentSizeCategory.medium):                            return 16
        case (UIFont.TextStyle.body, UIContentSizeCategory.large):                             return 17
        case (UIFont.TextStyle.body, UIContentSizeCategory.extraLarge):                        return 19
        case (UIFont.TextStyle.body, UIContentSizeCategory.extraExtraLarge):                   return 21
        case (UIFont.TextStyle.body, UIContentSizeCategory.extraExtraExtraLarge):              return 23
        case (UIFont.TextStyle.body, UIContentSizeCategory.accessibilityMedium):               return 28
        case (UIFont.TextStyle.body, UIContentSizeCategory.accessibilityLarge):                return 33
        case (UIFont.TextStyle.body, UIContentSizeCategory.accessibilityExtraLarge):           return 40
        case (UIFont.TextStyle.body, UIContentSizeCategory.accessibilityExtraExtraLarge):      return 47
        case (UIFont.TextStyle.body, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 53

        case (UIFont.TextStyle.callout, UIContentSizeCategory.extraSmall):                        return 13
        case (UIFont.TextStyle.callout, UIContentSizeCategory.small):                             return 14
        case (UIFont.TextStyle.callout, UIContentSizeCategory.medium):                            return 15
        case (UIFont.TextStyle.callout, UIContentSizeCategory.large):                             return 16
        case (UIFont.TextStyle.callout, UIContentSizeCategory.extraLarge):                        return 18
        case (UIFont.TextStyle.callout, UIContentSizeCategory.extraExtraLarge):                   return 20
        case (UIFont.TextStyle.callout, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.callout, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.callout, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.callout, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.callout, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.callout, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 22

        case (UIFont.TextStyle.footnote, UIContentSizeCategory.extraSmall):                        return 12
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.small):                             return 12
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.medium):                            return 12
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.large):                             return 13
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.extraLarge):                        return 15
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.extraExtraLarge):                   return 17
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.footnote, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 19

        case (UIFont.TextStyle.caption1, UIContentSizeCategory.extraSmall):                        return 11
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.small):                             return 11
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.medium):                            return 11
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.large):                             return 12
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.extraLarge):                        return 14
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.extraExtraLarge):                   return 16
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.caption1, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 18

        case (UIFont.TextStyle.caption2, UIContentSizeCategory.extraSmall):                        return 11
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.small):                             return 11
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.medium):                            return 11
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.large):                             return 11
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.extraLarge):                        return 13
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.extraExtraLarge):                   return 15
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFont.TextStyle.caption2, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 17

        default:
            return UIFontDescriptor.preferredFontDescriptor(withTextStyle: self).pointSize
        }
    }
}
