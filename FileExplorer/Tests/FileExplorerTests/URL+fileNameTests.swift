//
//  URL+fileNameTests.swift
//  Created by Nixon Shih on 2020/9/19.
//

import FileExplorer
import XCTest

final class URL_fileNameTests: XCTestCase {
    func testGetFileName() {
        let url = URL(string: "file:///home/pathA/file.swift")!
        XCTAssertEqual(url.fileName, "file.swift")
    }
    
    func testGetFileNameWithoutExtension() {
        let url = URL(string: "file:///home/pathA/file")!
        XCTAssertEqual(url.fileName, "file")
    }
}
