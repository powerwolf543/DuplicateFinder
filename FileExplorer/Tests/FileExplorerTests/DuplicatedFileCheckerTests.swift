//
//  DuplicatedFileCheckerTests.swift
//  Created by Nixon Shih on 2020/9/19.
//

@testable import FileExplorer
import XCTest

final class DuplicatedFileCheckerTests: XCTestCase {
    func testFindDuplicatedFiles() {
        let checker = DuplicatedFileChecker(excludedFiles: [], excludedPaths: [])

        // Check file.swift
        XCTAssertFalse(try checker.checkDuplicate(of: URL(string: "file:///home/pathA/file.swift")!))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift"])
        XCTAssertTrue(try checker.checkDuplicate(of: URL(string: "file:///home/pathB/file.swift")!))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift"])
        XCTAssertTrue(try checker.checkDuplicate(of: URL(string: "file:///home/pathC/file.swift")!))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift"])
        
        // Check otherFile.swift
        XCTAssertFalse(try checker.checkDuplicate(of: URL(string: "file:///home/pathA/otherFile.swift")!))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift", "otherFile.swift"])
        XCTAssertTrue(try checker.checkDuplicate(of: URL(string: "file:///home/pathB/otherFile.swift")!))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift", "otherFile.swift"])
        XCTAssertTrue(try checker.checkDuplicate(of: URL(string: "file:///home/pathC/otherFile.swift")!))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift", "otherFile.swift"])
    }
    
    func testURLIsSystemFile() throws {
        let urlA = URL(string: "file:///home/pathA/.DS_Store")!
        let urlB = URL(string: "file:///home/pathB/.DS_Store")!
        let checker = DuplicatedFileChecker(excludedFiles: [], excludedPaths: [])
        
        XCTAssertFalse(try checker.checkDuplicate(of: urlA))
        XCTAssertEqual(checker.checkedFileNames, [".DS_Store"])
        XCTAssertFalse(try checker.checkDuplicate(of: urlA))
        
        XCTAssertFalse(try checker.checkDuplicate(of: urlB))
        XCTAssertEqual(checker.checkedFileNames, [".DS_Store"])
        XCTAssertFalse(try checker.checkDuplicate(of: urlB))
    }
    
    func testURLIsExcludedPath() throws {
        let urlA = URL(string: "file:///home/pathA/file.swift")!
        let urlB = URL(string: "file:///home/pathB/file.swift")!
        let checker = DuplicatedFileChecker(excludedFiles: [], excludedPaths: [URL(string: "file:///home/pathB/")!])
        
        XCTAssertFalse(try checker.checkDuplicate(of: urlA))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift"])
        XCTAssertTrue(try checker.checkDuplicate(of: urlA))
        
        XCTAssertFalse(try checker.checkDuplicate(of: urlB))
        XCTAssertEqual(checker.checkedFileNames, ["file.swift"])
        XCTAssertFalse(try checker.checkDuplicate(of: urlB))
    }
    
    func testURLIsExcludedFile() throws {
        let urlA = URL(string: "file:///home/path/fileA.swift")!
        let urlB = URL(string: "file:///home/path/fileB.swift")!
        let checker = DuplicatedFileChecker(excludedFiles: ["fileB.swift"], excludedPaths: [])
        
        XCTAssertFalse(try checker.checkDuplicate(of: urlA))
        XCTAssertEqual(checker.checkedFileNames, ["fileA.swift"])
        XCTAssertTrue(try checker.checkDuplicate(of: urlA))
        
        XCTAssertFalse(try checker.checkDuplicate(of: urlB))
        XCTAssertEqual(checker.checkedFileNames, ["fileA.swift", "fileB.swift"])
        XCTAssertFalse(try checker.checkDuplicate(of: urlB))
    }
    
    func testNotFileURL() {
        let url = URL(string: "https://www.test.com")!
        let checker = DuplicatedFileChecker(excludedFiles: [], excludedPaths: [])
        
        do {
            _ = try checker.checkDuplicate(of: url)
            XCTFail("Should catch error")
        } catch {
            switch error {
            case DuplicatedFileChecker.Error.invalidFileURL:
                break
            default:
                XCTFail("Incorrect error")
            }
        }
    }
    
    func testURLIsDirectory() throws {
        let url = URL(string: "file:///home/path/")!
        let checker = DuplicatedFileChecker(excludedFiles: [], excludedPaths: [])
        
        let result = try checker.checkDuplicate(of: url)
        
        XCTAssertFalse(result)
    }
    
    func testInitialier() {
        var excludedFiles: Set<String> = ["FileA", "FileB"]
        let excludedPaths: Set<URL> = [
            URL(string: "file:///home/path/A/")!,
            URL(string: "file:///home/path/B/")!,
        ]
        
        let checker = DuplicatedFileChecker(excludedFiles: excludedFiles, excludedPaths: excludedPaths)
        
        for systemFile in SystemFile.allCases {
            excludedFiles.insert(systemFile.rawValue)
        }
        
        XCTAssertEqual(checker.excludedFiles, excludedFiles)
        XCTAssertEqual(checker.excludedPaths, excludedPaths)
        XCTAssertEqual(checker.checkedFileNames, [])
    }
}
