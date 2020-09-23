//
//  Storage.swift
//  Created by Nixon Shih on 2020/9/23.
//

import Foundation

/// A property wrapper that helps to store and retrieve `Value`.
@propertyWrapper
public final class Storage<Value> where Value: Codable {
    public var wrappedValue: Value {
        get {
            guard let data = projectedValue.retrieve(for: key),
                let value = try? JSONDecoder().decode(Value.self, from: data)
                else { return defaultValue }
            return value
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            projectedValue.store(data, for: key)
        }
    }
    
    public let key: String
    public let defaultValue: Value
    public let projectedValue: StoredContainer
    
    /// Creates `Storage` to store the value.
    /// - Parameters:
    ///   - key: A key with which to associate the value.
    ///   - defaultValue: A default value
    ///   - storedContainer: A underlying stored container which provides the storing and retrieving.
    public init(key: String, defaultValue: Value, storedContainer: StoredContainer = UserDefaults.standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.projectedValue = storedContainer
    }
}

