//
//  UserDefaults+StoredContainer.swift
//  Created by Nixon Shih on 2020/9/23.
//

import Foundation

extension UserDefaults: StoredContainer {
    public func store(_ value: Data, for key: String) {
        setValue(value, forKey: key)
    }
    
    public func retrieve(for key: String) -> Data? {
        data(forKey: key)
    }
}
