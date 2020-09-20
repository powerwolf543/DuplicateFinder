//
//  MockPathIterator.swift
//  Created by Nixon Shih on 2020/9/20.
//

@testable import FileExplorer
import Foundation

struct MockPathIterator: PathIterator {
    var urlIterator: IndexingIterator<[URL]>?
    
    init(urls: [URL]) {
        urlIterator = urls.makeIterator()
    }
    
    mutating func next() -> URL? {
        urlIterator?.next()
    }
}
