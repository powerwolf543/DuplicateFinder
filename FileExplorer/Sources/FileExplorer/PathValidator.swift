//
//  PathValidator.swift
//  Created by Nixon Shih on 2020/9/20.
//

import Foundation

/// A validator that verifies the paths which are needed.
internal struct PathValidator {
    /// The excluded informations, the `fileNames` also includes the `SystemFile` names.
    internal let excludedInfo: ExcludedInfo
    
    /// FilePathValidator initializer
    /// - Parameters:
    ///   - excludedInfo: The excluded informations
    internal init(excludedInfo: ExcludedInfo) {
        var excludedInfo = excludedInfo
        excludedInfo.fileNames = SystemFile.fileNames.reduce(into: excludedInfo.fileNames, { $0.insert($1) })
        self.excludedInfo = excludedInfo
    }
    
    /// Verifies the path is a file path.
    /// - Parameter path: A path which needs to verify
    /// - Returns: Return true, if the path is file path.
    internal func verifyPathIsFile(_ path: URL) -> Bool {
        path.isFileURL && !path.hasDirectoryPath
    }
    
    /// Verifies the path which needs to be excluded
    /// - Parameter path: A path which needs to verify
    /// - Returns: Return true, if the path need to be excluded
    internal func verifyPathNeedExcluded(_ path: URL) -> Bool {
        excludedInfo.fileNames.contains(path.fileName) ||
        !excludedInfo.directories.filter({ path.absoluteString.hasPrefix($0.absoluteString) }).isEmpty
    }
}
