//
//  MockStoredContainer.swift
//  Created by Nixon Shih on 2020/9/21.
//

import Utils
import XCTest

final class MockStoredContainer: StoredContainer {
    var map: [String: Data] = [:]
    
    func store(_ value: Data, for key: String) {
        map[key] = value
    }
    
    func retrieve(for key: String) -> Data? {
        map[key]
    }
}
