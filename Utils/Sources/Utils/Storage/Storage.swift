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
                let valueContainer = try? JSONDecoder().decode(WrappedValueContainer<Value>.self, from: data)
                else { return defaultValue }
            return valueContainer.value
        }
        set {
            let valueContainer = WrappedValueContainer(value: newValue)
            guard let data = try? JSONEncoder().encode(valueContainer) else { return }
            projectedValue.store(data, for: key)
        }
    }
    
    public let key: String
    public let defaultValue: Value
    public private(set) var projectedValue: StoredContainer
    
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

internal struct WrappedValueContainer<T>: Codable where T: Codable {
    internal let value: T
}
