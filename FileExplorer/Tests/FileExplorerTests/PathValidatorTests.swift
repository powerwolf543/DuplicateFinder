//
//  PathValidatorTests.swift
//  Created by Nixon Shih on 2020/9/21.
//

@testable import FileExplorer
import XCTest

final class PathValidatorTests: XCTestCase {
    func testURLIsSystemFile() {
        let urlA = URL(string: "file:///home/pathA/.DS_Store")!
        let urlB = URL(string: "file:///home/pathB/.DS_Store")!
        let pathValidator = PathValidator(excludedInfo: ExcludedInfo())

        XCTAssertTrue(pathValidator.verifyPathNeedExcluded(urlA))
        XCTAssertTrue(pathValidator.verifyPathNeedExcluded(urlB))
    }
    
    func testURLIsExcludedPath() {
        let urlA = URL(string: "file:///home/pathA/file.swift")!
        let urlB = URL(string: "file:///home/pathB/file.swift")!
        
        let excludedInfo = ExcludedInfo(directories: [URL(string: "file:///home/pathB/")!])
        let pathValidator = PathValidator(excludedInfo: excludedInfo)
        
        XCTAssertFalse(pathValidator.verifyPathNeedExcluded(urlA))
        XCTAssertTrue(pathValidator.verifyPathNeedExcluded(urlB))
    }
    
    func testURLIsExcludedFile() {
        let urlA = URL(string: "file:///home/path/fileA.swift")!
        let urlB = URL(string: "file:///home/path/fileB.swift")!
        
        let excludedInfo = ExcludedInfo(fileNames: ["fileB.swift"])
        let pathValidator = PathValidator(excludedInfo: excludedInfo)
        
        XCTAssertFalse(pathValidator.verifyPathNeedExcluded(urlA))
        XCTAssertTrue(pathValidator.verifyPathNeedExcluded(urlB))
    }
    
    func testNotFileURL() {
        let url = URL(string: "https://www.test.com")!
        let pathValidator = PathValidator(excludedInfo: ExcludedInfo())

        let result = pathValidator.verifyPathIsFile(url)
        
        XCTAssertFalse(result)
    }
    
    func testURLIsDirectory() {
        let url = URL(string: "file:///home/path/")!
        let pathValidator = PathValidator(excludedInfo: ExcludedInfo())
        
        let result = pathValidator.verifyPathIsFile(url)
        
        XCTAssertFalse(result)
    }
    
    func testInitialier() {
        var excludedFiles: Set<String> = ["FileA", "FileB"]
        let excludedPaths: Set<URL> = [
            URL(string: "file:///home/path/A/")!,
            URL(string: "file:///home/path/B/")!,
        ]
        
        let excludedInfo = ExcludedInfo(fileNames: excludedFiles, directories: excludedPaths)
        let pathValidator = PathValidator(excludedInfo: excludedInfo)
                
        for systemFile in SystemFile.allCases {
            excludedFiles.insert(systemFile.rawValue)
        }
        
        XCTAssertEqual(pathValidator.excludedInfo.fileNames, excludedFiles)
        XCTAssertEqual(pathValidator.excludedInfo.directories, excludedPaths)
    }
}
