//
//  FileExplorerTests.swift
//  Created by Nixon Shih on 2020/9/20.
//

@testable import FileExplorer
import XCTest

final class FileExplorerTests: XCTestCase {
    func testFindDuplicatedFile() {
        let input: [URL] = testData
        
        let pathIterator = MockPathIterator(urls: input)
        let explorer = FileExplorer()
        
        let searchExpectation = expectation(description: "The search should be done.")
        
        explorer.findDuplicatedFile(with: pathIterator) { result in
            switch result {
            case .success(let paths):
                let outputs = paths.reduce(into: Set<URL>()) { $0.insert($1) }
                let expectedResult: Set<URL> = [
                    URL(string: "file:///home/a.swift")!,
                    URL(string: "file:///home/path/a.swift")!,
                    URL(string: "file:///home/b.swift")!,
                    URL(string: "file:///home/path/b.swift")!,
                    URL(string: "file:///home/path/path/b.swift")!,
                ]
                XCTAssertEqual(outputs, expectedResult)
                
            case .failure:
                XCTFail("This case should be success.")
            }
            searchExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFindDuplicatedFileWithExcludedFile() {
        let input: [URL] = testData
        
        let pathIterator = MockPathIterator(urls: input)
        let excludedInfo = ExcludedInfo(fileNames: ["a.swift"])
        let explorer = FileExplorer(excludedInfo: excludedInfo)
        
        let searchExpectation = expectation(description: "The search should be done.")
        
        explorer.findDuplicatedFile(with: pathIterator) { result in
            switch result {
            case .success(let paths):
                let outputs = paths.reduce(into: Set<URL>()) { $0.insert($1) }
                let expectedResult: Set<URL> = [
                    URL(string: "file:///home/b.swift")!,
                    URL(string: "file:///home/path/b.swift")!,
                    URL(string: "file:///home/path/path/b.swift")!,
                ]
                XCTAssertEqual(outputs, expectedResult)
                
            case .failure:
                XCTFail("This case should be success.")
            }
            searchExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFindDuplicatedFileWithExcludedPath() {
        let input: [URL] = testData
        
        let pathIterator = MockPathIterator(urls: input)
        let excludedInfo = ExcludedInfo(directories: [URL(string: "file:///home/path/")!])
        let explorer = FileExplorer(excludedInfo: excludedInfo)
        
        let searchExpectation = expectation(description: "The search should be done.")
        
        explorer.findDuplicatedFile(with: pathIterator) { result in
            switch result {
            case .success(let paths):
                let outputs = paths.reduce(into: Set<URL>()) { $0.insert($1) }
                      let expectedResult: Set<URL> = [
                          URL(string: "file:///home/a.swift")!,
                          URL(string: "file:///home/b.swift")!,
                      ]
                      XCTAssertEqual(outputs, expectedResult)
                
            case .failure:
                XCTFail("This case should be success.")
            }
            searchExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testGroupListByName() {
        let groupedList: [String: Set<URL>] = [
            "a.swift" : [
                URL(string: "file:///home/a.swift")!,
                URL(string: "file:///home/path/a.swift")!
            ],
            "b.swift" : [
                URL(string: "file:///home/b.swift")!,
                URL(string: "file:///home/path/b.swift")!,
                URL(string: "file:///home/path/path/b.swift")!
            ]
        ]
        
        let explorer = FileExplorer()
        let pathIterator = MockPathIterator(urls: groupedList.flatMap({ $0.value }))
        
        let result = explorer.groupListByName(with: pathIterator)
        
        XCTAssertEqual(result, groupedList)
    }
    
    var testData: [URL] {
        [
            URL(string: "file:///home/path/0.swift")!,
            URL(string: "file:///home/a.swift")!,
            URL(string: "file:///home/path/a.swift")!,
            URL(string: "file:///home/b.swift")!,
            URL(string: "file:///home/path/b.swift")!,
            URL(string: "file:///home/path/path/b.swift")!,
            URL(string: "file:///home/path/path/c.swift")!,
            URL(string: "file:///home/path/path/d.swift")!,
        ]
    }
}

