//
//  DynamicType.swift
//  DynamicTypeExample
//
//  Created by Ian Terrell on 8/4/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

final class FontMap<Style: Hashable> {
    let creator: (style: Style, sizeCategory: UIContentSizeCategory) -> UIFont
    var cache: [Style: [UIContentSizeCategory:UIFont]] = [:]

    init(creator: (style: Style, sizeCategory: UIContentSizeCategory) -> UIFont) {
        self.creator = creator
    }

    func font(style: Style, sizeCategory: UIContentSizeCategory) -> UIFont {
        if let font = cache[style]?[sizeCategory] {
            return font
        }

        let font = creator(style: style, sizeCategory: sizeCategory)
        cache[style] = cache[style] ?? [:]
        cache[style]?[sizeCategory] = font
        return font
    }
}

public enum TextStyle {
    case title1
    case title2
    case title3
    case headline
    case subheadline
    case body
    case callout
    case footnote
    case caption1
    case caption2

    var osTextStyle: String {
        switch self {
        case .title1:      return UIFontTextStyleTitle1
        case .title2:      return UIFontTextStyleTitle2
        case .title3:      return UIFontTextStyleTitle3
        case .headline:    return UIFontTextStyleHeadline
        case .subheadline: return UIFontTextStyleSubheadline
        case .body:        return UIFontTextStyleBody
        case .callout:     return UIFontTextStyleCallout
        case .footnote:    return UIFontTextStyleFootnote
        case .caption1:    return UIFontTextStyleCaption1
        case .caption2:    return UIFontTextStyleCaption2
        }
    }

    static let defaultFontMap = FontMap<TextStyle>(creator: TextStyle.defaultFontMapping)
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

private extension Selector {
    static let updateFonts = #selector(UIViewController.dynamicType_updateFonts(notification:))
}

let DynamicTypeSizeCategories: [UIContentSizeCategory] = [
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

extension TextStyle {
    static func defaultFontMapping(style: TextStyle, sizeCategory: UIContentSizeCategory) -> UIFont {
        switch (style, sizeCategory) {
        case (.title1, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 25)
        case (.title1, UIContentSizeCategory.small):                             return .systemFont(ofSize: 26)
        case (.title1, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 27)
        case (.title1, UIContentSizeCategory.large):                             return .systemFont(ofSize: 28)
        case (.title1, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 30)
        case (.title1, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 32)
        case (.title1, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.title1, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.title1, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.title1, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.title1, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.title1, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 34)

        case (.title2, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 19)
        case (.title2, UIContentSizeCategory.small):                             return .systemFont(ofSize: 20)
        case (.title2, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 21)
        case (.title2, UIContentSizeCategory.large):                             return .systemFont(ofSize: 22)
        case (.title2, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 24)
        case (.title2, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 26)
        case (.title2, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.title2, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.title2, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.title2, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.title2, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.title2, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 28)

        case (.title3, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 17)
        case (.title3, UIContentSizeCategory.small):                             return .systemFont(ofSize: 18)
        case (.title3, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 19)
        case (.title3, UIContentSizeCategory.large):                             return .systemFont(ofSize: 20)
        case (.title3, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 22)
        case (.title3, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 24)
        case (.title3, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.title3, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.title3, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.title3, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.title3, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.title3, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 26)

        case (.headline, UIContentSizeCategory.extraSmall):                        return .boldSystemFont(ofSize: 14)
        case (.headline, UIContentSizeCategory.small):                             return .boldSystemFont(ofSize: 15)
        case (.headline, UIContentSizeCategory.medium):                            return .boldSystemFont(ofSize: 16)
        case (.headline, UIContentSizeCategory.large):                             return .boldSystemFont(ofSize: 17)
        case (.headline, UIContentSizeCategory.extraLarge):                        return .boldSystemFont(ofSize: 19)
        case (.headline, UIContentSizeCategory.extraExtraLarge):                   return .boldSystemFont(ofSize: 21)
        case (.headline, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.headline, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.headline, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.headline, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.headline, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.headline, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .boldSystemFont(ofSize: 23)

        case (.subheadline, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 12)
        case (.subheadline, UIContentSizeCategory.small):                             return .systemFont(ofSize: 13)
        case (.subheadline, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 14)
        case (.subheadline, UIContentSizeCategory.large):                             return .systemFont(ofSize: 15)
        case (.subheadline, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 17)
        case (.subheadline, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 19)
        case (.subheadline, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.subheadline, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.subheadline, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.subheadline, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.subheadline, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.subheadline, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 21)

        case (.body, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 14)
        case (.body, UIContentSizeCategory.small):                             return .systemFont(ofSize: 15)
        case (.body, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 16)
        case (.body, UIContentSizeCategory.large):                             return .systemFont(ofSize: 17)
        case (.body, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 19)
        case (.body, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 21)
        case (.body, UIContentSizeCategory.extraExtraExtraLarge):              return .systemFont(ofSize: 23)
        case (.body, UIContentSizeCategory.accessibilityMedium):               return .systemFont(ofSize: 28)
        case (.body, UIContentSizeCategory.accessibilityLarge):                return .systemFont(ofSize: 33)
        case (.body, UIContentSizeCategory.accessibilityExtraLarge):           return .systemFont(ofSize: 40)
        case (.body, UIContentSizeCategory.accessibilityExtraExtraLarge):      return .systemFont(ofSize: 47)
        case (.body, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 53)

        case (.callout, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 13)
        case (.callout, UIContentSizeCategory.small):                             return .systemFont(ofSize: 14)
        case (.callout, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 15)
        case (.callout, UIContentSizeCategory.large):                             return .systemFont(ofSize: 16)
        case (.callout, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 18)
        case (.callout, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 20)
        case (.callout, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.callout, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.callout, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.callout, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.callout, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.callout, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 22)

        case (.footnote, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 12)
        case (.footnote, UIContentSizeCategory.small):                             return .systemFont(ofSize: 12)
        case (.footnote, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 12)
        case (.footnote, UIContentSizeCategory.large):                             return .systemFont(ofSize: 13)
        case (.footnote, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 15)
        case (.footnote, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 17)
        case (.footnote, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.footnote, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.footnote, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.footnote, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.footnote, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.footnote, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 19)

        case (.caption1, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 11)
        case (.caption1, UIContentSizeCategory.small):                             return .systemFont(ofSize: 11)
        case (.caption1, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 11)
        case (.caption1, UIContentSizeCategory.large):                             return .systemFont(ofSize: 12)
        case (.caption1, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 14)
        case (.caption1, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 16)
        case (.caption1, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.caption1, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.caption1, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.caption1, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.caption1, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.caption1, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 18)

        case (.caption2, UIContentSizeCategory.extraSmall):                        return .systemFont(ofSize: 11)
        case (.caption2, UIContentSizeCategory.small):                             return .systemFont(ofSize: 11)
        case (.caption2, UIContentSizeCategory.medium):                            return .systemFont(ofSize: 11)
        case (.caption2, UIContentSizeCategory.large):                             return .systemFont(ofSize: 11)
        case (.caption2, UIContentSizeCategory.extraLarge):                        return .systemFont(ofSize: 13)
        case (.caption2, UIContentSizeCategory.extraExtraLarge):                   return .systemFont(ofSize: 15)
        case (.caption2, UIContentSizeCategory.extraExtraExtraLarge):              fallthrough
        case (.caption2, UIContentSizeCategory.accessibilityMedium):               fallthrough
        case (.caption2, UIContentSizeCategory.accessibilityLarge):                fallthrough
        case (.caption2, UIContentSizeCategory.accessibilityExtraLarge):           fallthrough
        case (.caption2, UIContentSizeCategory.accessibilityExtraExtraLarge):      fallthrough
        case (.caption2, UIContentSizeCategory.accessibilityExtraExtraExtraLarge): return .systemFont(ofSize: 17)
            
        default:
            return .preferredFont(forTextStyle: style.osTextStyle)
        }
    }
}
