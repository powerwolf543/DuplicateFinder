//
//  SearchResult.swift
//  CheckSameFileName
//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Foundation

/**
 **SearchResult**
 
 
 這個 Struct 是存放搜尋資料的Model
 */
struct SearchResult {
    
    let fileURL: URL
    
    var fileName: String {
        return fileURL.lastPathComponent
    }
    
    var filePath: String {
        return fileURL.absoluteString
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
}
