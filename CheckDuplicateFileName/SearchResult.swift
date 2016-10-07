//
//  SearchResult.swift
//  CheckSameFileName
//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Foundation

class SearchResult {
    
    let fileURL: NSURL
    
    var fileName: String {
        if let theFileName = fileURL.lastPathComponent {
            return theFileName
        }else{
            return ""
        }
    }
    
    var filePath: String {
        return fileURL.absoluteString
    }
    
    init(fileURL: NSURL) {
        self.fileURL = fileURL
    }
}