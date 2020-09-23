//
//  String+Localized.swift
//  Created by Nixon Shih on 2020/9/23.
//

import Foundation

/// Convenience extension of localized string
extension String {
    /// use this syntax to replace NSLocalizedString
    public var localized: String {
        localized(using: nil, in: Localization.currentBundle)
    }

    /**
     use this syntax to replace NSLocalizedString with format string.
     - parameter arguments: arguments values for temlpate
     - returns: The formatted localized string with arguments.
     */
    public func localizedFormat(with arguments: CVarArg...) -> String {
        String(format: localized, arguments: arguments)
    }

    private func localized(using tableName: String?, in bundle: Bundle?) -> String {
        let bundle: Bundle = bundle ?? .main
        if let path = bundle.path(forResource: Localization.currentLanguage, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        } else if let path = bundle.path(forResource: "Base", ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        return self
    }
}
