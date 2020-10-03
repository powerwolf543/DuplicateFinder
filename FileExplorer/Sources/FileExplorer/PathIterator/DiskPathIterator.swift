//
//  DiskPathIterator.swift
//  Created by Nixon Shih on 2020/9/16.
//

import Foundation

/// An Iterator that enumerates the contents of a directory.
public struct DiskPathIterator: PathIterator {
    private let directoryEnumerator: FileManager.DirectoryEnumerator
    
    public init?(directoryURL: URL, isSkipsHiddenFiles: Bool, fileManager: FileManager = .default) {
        guard let directoryEnumerator = fileManager.createDirectoryEnumerator(for: directoryURL, isSkipsHiddenFiles: isSkipsHiddenFiles) else { return nil }
        self.directoryEnumerator = directoryEnumerator
    }
    
    /// The next element in the underlying sequence, if a next element
    /// exists; otherwise, `nil`.
    public func next() -> URL? {
        directoryEnumerator.nextObject() as? URL
    }
}

extension FileManager {
    fileprivate func createDirectoryEnumerator(for directoryURL: URL, isSkipsHiddenFiles: Bool) -> FileManager.DirectoryEnumerator? {
        let options: FileManager.DirectoryEnumerationOptions = isSkipsHiddenFiles ? .skipsHiddenFiles : []
        
        guard let directoryEnumerator = enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
            options: options
            ) else { return nil }
        
        return directoryEnumerator
    }
}
