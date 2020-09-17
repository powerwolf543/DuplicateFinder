//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Foundation

/// SearchResult
///
/// Include a result of file search
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
