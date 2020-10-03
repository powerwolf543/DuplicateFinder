//
//  StoredContainer.swift
//  Created by Nixon Shih on 2020/9/23.
//

import Foundation

/// A protocol that defines the interface to store and retrieve value.
public protocol StoredContainer {
    mutating func store(_ value: Data, for key: String)
    func retrieve(for key: String) -> Data?
}
