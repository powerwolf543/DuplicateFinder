//
//  URL+fileName.swift
//  Created by Nixon Shih on 2020/9/19.
//

import Foundation

public extension URL {
    /// Get the file name from URL
    var fileName: String { lastPathComponent }
}
