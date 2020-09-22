//
//  ExcludedInfo.swift
//  Created by Nixon Shih on 2020/9/21.
//

import Foundation

/// A data structure that represents all the informations which need to be excluded
public struct ExcludedInfo {
    /// A `String` set that includes all the file names which need to be excluded
    public var fileNames: Set<String> = []
    /// A `URL` set that includes all the paths of directories which need to be excluded
    public var directories: Set<URL> = []
    
    public init(fileNames: Set<String> = [], directories: Set<URL> = []) {
        self.fileNames = fileNames
        self.directories = directories
    }
}
