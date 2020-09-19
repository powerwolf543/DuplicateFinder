//
//  DiskPathIterator.swift
//  Created by Nixon Shih on 2020/9/16.
//

import Foundation

/// An Iterator that enumerates the contents of a directory.
internal struct DiskPathIterator: PathIterator {
    private let directoryEnumerator: FileManager.DirectoryEnumerator
    
    internal init?(directoryURL: URL, isSkipsHiddenFiles: Bool, fileManager: FileManager = .default) {
        let options: FileManager.DirectoryEnumerationOptions = isSkipsHiddenFiles ? .skipsHiddenFiles : []
        
        guard let directoryEnumerator = fileManager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: [URLResourceKey.isDirectoryKey],
            options: options
            ) else { return nil }
        
        self.directoryEnumerator = directoryEnumerator
    }
    
    /// The next element in the underlying sequence, if a next element
    /// exists; otherwise, `nil`.
    internal mutating func next() -> URL? {
        directoryEnumerator.nextObject() as? URL
    }
    
}
