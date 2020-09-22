//
//  MockPathIterator.swift
//  Created by Nixon Shih on 2020/9/20.
//

@testable import FileExplorer
import Foundation

final class MockPathIterator: PathIterator {
    var urlIterator: IndexingIterator<[URL]>?
    
    init(urls: [URL]) {
        urlIterator = urls.makeIterator()
    }
    
    func next() -> URL? {
        urlIterator?.next()
    }
}
