//
//  String+Localized.swift
//  Created by Nixon Shih on 2020/9/23.
//

import Foundation

/// Convenience extension of localized string
extension String {
    /// Uses this syntax to replace NSLocalizedString
    public var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /**
     Uses this syntax to replace NSLocalizedString with format string.
     - parameter arguments: Arguments for temlpate
     - returns: The formatted localized string with arguments.
     */
    public func localizedFormat(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }
}
