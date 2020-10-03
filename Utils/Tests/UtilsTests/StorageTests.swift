//
//  StorageTests.swift
//  Created by Nixon Shih on 2020/9/21.
//

@testable import Utils
import XCTest

final class StorageTests: XCTestCase {
    func testStoreData() throws {
        let key = "key"
        let text = "test"
        let container = MockStoredContainer()
        
        let storage = Storage<String>(key: key, defaultValue: "", storedContainer: container)
        storage.wrappedValue = text
        
        let expectedResult = try createExpectedResult(value: text)
        XCTAssertEqual(container.map[key], expectedResult)
    }
    
    func testRetrieveData() throws {
        let key = "key"
        let text = "test"
        let input = try createExpectedResult(value: text)
        
        let container = MockStoredContainer()
        container.map[key] = input
        
        let storage = Storage<String>(key: key, defaultValue: "", storedContainer: container)
        let result = storage.wrappedValue
        
        XCTAssertEqual(result, text)
    }
    
    func testRetrieveDefaultValue() {
        let key = "key"
        let defaultValue = "default"
        let container = MockStoredContainer()
        let storage = Storage<String>(key: key, defaultValue: defaultValue, storedContainer: container)
        let result = storage.wrappedValue

        XCTAssertEqual(result, defaultValue)
    }
    
    func createExpectedResult<T>(value: T) throws -> Data where T: Codable {
        let container = WrappedValueContainer(value: value)
        return try JSONEncoder().encode(container)
    }
}
