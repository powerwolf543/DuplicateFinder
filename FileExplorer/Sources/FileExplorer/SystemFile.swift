//
//  SystemFile.swift
//  Created by Nixon Shih on 2020/9/16.
//

import Foundation

/// The MacOS system file
internal enum SystemFile: String, CaseIterable {
    static let fileNames: Set<String> = {
        SystemFile.allCases.reduce(into: Set<String>()) { $0.insert($1.rawValue) }
    }()
    
    case dsStore = ".DS_Store"
    case macOSX = "__MACOSX"
}
