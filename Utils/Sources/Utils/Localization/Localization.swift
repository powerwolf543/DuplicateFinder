//
//  Localization.swift
//  Created by Nixon Shih on 2020/9/23.
//

import Foundation
 
/// The tool to make the localization elegant
public final class Localization {
    @Storage(key: currentLanguageUserDefaultsKey, defaultValue: defaultLanguage())
    public static var currentLanguage: String
    
    /// The bundle of Localization.
    internal static var currentBundle: Bundle? { Bundle(for: self) }

    private static let currentLanguageUserDefaultsKey = "net.nixondesign.FindDuplicateFileName.Localization"
    private static let localizationDefaultLanguage = "en"

    /**
     List available languages
     - Returns: Array of available languages.
     */
    public class func availableLanguages(_ excludeBase: Bool = false) -> [String] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.firstIndex(of: "Base"), excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }

    /**
     Default language
     - Returns: The app's default language. String.
     */
    public class func defaultLanguage() -> String {
        var defaultLanguage: String = ""
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return localizationDefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if availableLanguages.contains(preferredLanguage) {
            defaultLanguage = preferredLanguage
        } else {
            defaultLanguage = localizationDefaultLanguage
        }
        return defaultLanguage
    }

    /**
     Get the current language's display name for a language.
     - Parameter language: Desired language.
     - Returns: The localized string.
     */
    public class func displayNameForLanguage(_ language: String) -> String {
        let locale: NSLocale = NSLocale(localeIdentifier: currentLanguage)
        if let displayName = locale.displayName(forKey: NSLocale.Key.identifier, value: language) {
            return displayName
        }
        return ""
    }
}
