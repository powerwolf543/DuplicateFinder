//
//  File.swift
//  Created by Nixon Shih on 2020/9/16.
//

import Foundation

public struct File {
    public let url: URL
    public var fileName: String { url.lastPathComponent }
    public var filePath: String { url.absoluteString }
}
