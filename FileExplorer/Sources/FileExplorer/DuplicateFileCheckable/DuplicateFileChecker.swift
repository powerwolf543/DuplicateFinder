//
//  DuplicateFileChecker.swift
//  Created by Nixon Shih on 2020/9/19.
//

import Foundation

/// A file name checker that checks the file name is duplicated within whole search.
internal final class DuplicateFileChecker: DuplicateFileCheckable {
    /// The file names that will be excluded, it also includes the `SystemFile` names.
    internal private(set) var excludedFiles: Set<String>
    /// The paths that will be excluded
    internal private(set) var excludedPaths: Set<URL>
    // The file names that has been checked
    internal private(set) var checkedFileNames: Set<String>
    
    /// DuplicateFileChecker initializer
    /// - Parameters:
    ///   - excludedFiles: The file names that will be excluded
    ///   - excludedPaths: The paths that will be excluded
    internal init(excludedFiles: Set<String>, excludedPaths: Set<URL>) {
        self.excludedFiles = SystemFile.fileNames.reduce(into: excludedFiles, { $0.insert($1) })
        self.excludedPaths = excludedPaths
        checkedFileNames = []
    }
    
    /// To check the file name is duplicated within whole search.
    /// - Parameter fileURL: A URL that you want to check.
    /// - Throws: DuplicateFileChecker.Error.invalidFileURL
    /// - Returns: Return true if the checker finds the duplicated file name.
    internal func checkDuplicate(of fileURL: URL) throws -> Bool {
        guard fileURL.isFileURL else { throw Error.invalidFileURL }
        guard !fileURL.hasDirectoryPath else { return false }
        
        defer { checkedFileNames.insert(fileURL.fileName) }
        
        return checkedFileNames.contains(fileURL.fileName) &&
            !excludedFiles.contains(fileURL.fileName) &&
            excludedPaths.filter({ fileURL.absoluteString.hasPrefix($0.absoluteString) }).isEmpty
    }
}

extension DuplicateFileChecker {
    enum Error: LocalizedError {
        case invalidFileURL
    }
}
