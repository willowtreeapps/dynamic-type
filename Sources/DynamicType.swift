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

    init(creator: @escaping (_ style: Style, _ sizeCategory: UIContentSizeCategory) -> UIFont) {
        self.creator = creator
    }

    public func font(style: Style, sizeCategory: UIContentSizeCategory) -> UIFont {
        if let font = cache[style]?[sizeCategory] {
            return font
        }

        let font = creator(style, sizeCategory)
        cache[style] = cache[style] ?? [:]
        cache[style]?[sizeCategory] = font
        return font
    }
}

extension UIFontTextStyle {
    /// A default font map for default styles
    public static let defaultFontMap = FontMap<UIFontTextStyle>(creator: defaultFontMapping)
}

@objc protocol RespondsToDynamicFont {
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

    func dynamicType_viewDidLoad() {
        self.dynamicType_viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: .updateFonts,
                                               name: .UIContentSizeCategoryDidChange,
                                               object: nil)
    }

    func dynamicType_updateFonts(notification: Notification) {
        guard let responder = self as? RespondsToDynamicFont,
              let preference = notification.userInfo?[UIContentSizeCategoryNewValueKey] as? UIContentSizeCategory
        else {
            return
        }

        responder.updateFonts(preferredContentSize: preference)
    }

    static func dynamicType_swizzleMethod(_ original: Selector, swizzled: Selector) {
        let originalMethod = class_getInstanceMethod(self, original)
        let swizzledMethod = class_getInstanceMethod(self, swizzled)

        let didAddMethod = class_addMethod(self, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if didAddMethod {
            class_replaceMethod(self, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
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

extension UIFontTextStyle {
    public static func defaultFontMapping(style: UIFontTextStyle, sizeCategory: UIContentSizeCategory) -> UIFont {
        return style.defaultFontMapping(sizeCategory: sizeCategory)
    }

    /// The iOS default font for a given size category.
    public func defaultFontMapping(sizeCategory: UIContentSizeCategory) -> UIFont {
        let pointSize = defaultFontPointSize(sizeCategory: sizeCategory)

        switch self {
        case UIFontTextStyle.headline:
            return .boldSystemFont(ofSize: pointSize)
        default:
            return .systemFont(ofSize: pointSize)
        }
    }
}

extension UIFontTextStyle {
    /// The iOS defaults for font sizes for a given style and size category.
    public func defaultFontPointSize(sizeCategory: UIContentSizeCategory) -> CGFloat {
        switch (self, sizeCategory) {
        case (UIFontTextStyle.title1, UIContentSizeCategory.extraSmall):                        return 25
        case (UIFontTextStyle.title1, UIContentSizeCategory.small):                             return 26
        case (UIFontTextStyle.title1, UIContentSizeCategory.medium):                            return 27
        case (UIFontTextStyle.title1, UIContentSizeCategory.large):                             return 28
        case (UIFontTextStyle.title1, UIContentSizeCategory.extraLarge):                        return 30
        case (UIFontTextStyle.title1, UIContentSizeCategory.extraExtraLarge):                   return 32
        case (UIFontTextStyle.title1, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.title1, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.title1, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.title1, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.title1, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.title1, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 34

        case (UIFontTextStyle.title2, UIContentSizeCategory.extraSmall):                        return 19
        case (UIFontTextStyle.title2, UIContentSizeCategory.small):                             return 20
        case (UIFontTextStyle.title2, UIContentSizeCategory.medium):                            return 21
        case (UIFontTextStyle.title2, UIContentSizeCategory.large):                             return 22
        case (UIFontTextStyle.title2, UIContentSizeCategory.extraLarge):                        return 24
        case (UIFontTextStyle.title2, UIContentSizeCategory.extraExtraLarge):                   return 26
        case (UIFontTextStyle.title2, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.title2, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.title2, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.title2, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.title2, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.title2, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 28

        case (UIFontTextStyle.title3, UIContentSizeCategory.extraSmall):                        return 17
        case (UIFontTextStyle.title3, UIContentSizeCategory.small):                             return 18
        case (UIFontTextStyle.title3, UIContentSizeCategory.medium):                            return 19
        case (UIFontTextStyle.title3, UIContentSizeCategory.large):                             return 20
        case (UIFontTextStyle.title3, UIContentSizeCategory.extraLarge):                        return 22
        case (UIFontTextStyle.title3, UIContentSizeCategory.extraExtraLarge):                   return 24
        case (UIFontTextStyle.title3, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.title3, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.title3, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.title3, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.title3, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.title3, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 26

        case (UIFontTextStyle.headline, UIContentSizeCategory.extraSmall):                        return 14
        case (UIFontTextStyle.headline, UIContentSizeCategory.small):                             return 15
        case (UIFontTextStyle.headline, UIContentSizeCategory.medium):                            return 16
        case (UIFontTextStyle.headline, UIContentSizeCategory.large):                             return 17
        case (UIFontTextStyle.headline, UIContentSizeCategory.extraLarge):                        return 19
        case (UIFontTextStyle.headline, UIContentSizeCategory.extraExtraLarge):                   return 21
        case (UIFontTextStyle.headline, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.headline, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.headline, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.headline, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.headline, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.headline, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 23

        case (UIFontTextStyle.subheadline, UIContentSizeCategory.extraSmall):                        return 12
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.small):                             return 13
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.medium):                            return 14
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.large):                             return 15
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.extraLarge):                        return 17
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.extraExtraLarge):                   return 19
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.subheadline, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 21

        case (UIFontTextStyle.body, UIContentSizeCategory.extraSmall):                        return 14
        case (UIFontTextStyle.body, UIContentSizeCategory.small):                             return 15
        case (UIFontTextStyle.body, UIContentSizeCategory.medium):                            return 16
        case (UIFontTextStyle.body, UIContentSizeCategory.large):                             return 17
        case (UIFontTextStyle.body, UIContentSizeCategory.extraLarge):                        return 19
        case (UIFontTextStyle.body, UIContentSizeCategory.extraExtraLarge):                   return 21
        case (UIFontTextStyle.body, UIContentSizeCategory.extraExtraExtraLarge):              return 23
        case (UIFontTextStyle.body, UIContentSizeCategory.accessibilityMedium):               return 28
        case (UIFontTextStyle.body, UIContentSizeCategory.accessibilityLarge):                return 33
        case (UIFontTextStyle.body, UIContentSizeCategory.accessibilityExtraLarge):           return 40
        case (UIFontTextStyle.body, UIContentSizeCategory.accessibilityExtraExtraLarge):      return 47
        case (UIFontTextStyle.body, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 53

        case (UIFontTextStyle.callout, UIContentSizeCategory.extraSmall):                        return 13
        case (UIFontTextStyle.callout, UIContentSizeCategory.small):                             return 14
        case (UIFontTextStyle.callout, UIContentSizeCategory.medium):                            return 15
        case (UIFontTextStyle.callout, UIContentSizeCategory.large):                             return 16
        case (UIFontTextStyle.callout, UIContentSizeCategory.extraLarge):                        return 18
        case (UIFontTextStyle.callout, UIContentSizeCategory.extraExtraLarge):                   return 20
        case (UIFontTextStyle.callout, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.callout, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.callout, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.callout, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.callout, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.callout, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 22

        case (UIFontTextStyle.footnote, UIContentSizeCategory.extraSmall):                        return 12
        case (UIFontTextStyle.footnote, UIContentSizeCategory.small):                             return 12
        case (UIFontTextStyle.footnote, UIContentSizeCategory.medium):                            return 12
        case (UIFontTextStyle.footnote, UIContentSizeCategory.large):                             return 13
        case (UIFontTextStyle.footnote, UIContentSizeCategory.extraLarge):                        return 15
        case (UIFontTextStyle.footnote, UIContentSizeCategory.extraExtraLarge):                   return 17
        case (UIFontTextStyle.footnote, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.footnote, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.footnote, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.footnote, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.footnote, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.footnote, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 19

        case (UIFontTextStyle.caption1, UIContentSizeCategory.extraSmall):                        return 11
        case (UIFontTextStyle.caption1, UIContentSizeCategory.small):                             return 11
        case (UIFontTextStyle.caption1, UIContentSizeCategory.medium):                            return 11
        case (UIFontTextStyle.caption1, UIContentSizeCategory.large):                             return 12
        case (UIFontTextStyle.caption1, UIContentSizeCategory.extraLarge):                        return 14
        case (UIFontTextStyle.caption1, UIContentSizeCategory.extraExtraLarge):                   return 16
        case (UIFontTextStyle.caption1, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.caption1, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.caption1, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.caption1, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.caption1, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.caption1, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 18

        case (UIFontTextStyle.caption2, UIContentSizeCategory.extraSmall):                        return 11
        case (UIFontTextStyle.caption2, UIContentSizeCategory.small):                             return 11
        case (UIFontTextStyle.caption2, UIContentSizeCategory.medium):                            return 11
        case (UIFontTextStyle.caption2, UIContentSizeCategory.large):                             return 11
        case (UIFontTextStyle.caption2, UIContentSizeCategory.extraLarge):                        return 13
        case (UIFontTextStyle.caption2, UIContentSizeCategory.extraExtraLarge):                   return 15
        case (UIFontTextStyle.caption2, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (UIFontTextStyle.caption2, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (UIFontTextStyle.caption2, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (UIFontTextStyle.caption2, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (UIFontTextStyle.caption2, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (UIFontTextStyle.caption2, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return 17

        default:
            return UIFontDescriptor.preferredFontDescriptor(withTextStyle: self).pointSize
        }
    }
}
