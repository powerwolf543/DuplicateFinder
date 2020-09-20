//
//  DiskPathIterator.swift
//  Created by Nixon Shih on 2020/9/16.
//

import Foundation

/// An Iterator that enumerates the contents of a directory.
public struct DiskPathIterator: PathIterator {
    private let directoryEnumerator: FileManager.DirectoryEnumerator
    
    public init?(configuration: Configuration, fileManager: FileManager = .default) {
        guard let directoryEnumerator = fileManager.createDirectoryEnumerator(with: configuration) else { return nil }
        self.directoryEnumerator = directoryEnumerator
    }
    
    /// The next element in the underlying sequence, if a next element
    /// exists; otherwise, `nil`.
    public mutating func next() -> URL? {
        directoryEnumerator.nextObject() as? URL
    }
}

extension DiskPathIterator {
    public struct Configuration {
        public let directoryURL: URL
        public let isSkipsHiddenFiles: Bool
        
        public init(directoryURL: URL, isSkipsHiddenFiles: Bool) {
            self.directoryURL = directoryURL
            self.isSkipsHiddenFiles = isSkipsHiddenFiles
        }
    }
}

extension FileManager {
    fileprivate func createDirectoryEnumerator(with config: DiskPathIterator.Configuration) -> FileManager.DirectoryEnumerator? {
        let options: FileManager.DirectoryEnumerationOptions = config.isSkipsHiddenFiles ? .skipsHiddenFiles : []
        
        guard let directoryEnumerator = enumerator(
            at: config.directoryURL,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
            options: options
            ) else { return nil }
        
        return directoryEnumerator
    }
}
