//
//  Created by Nixon Shih on 2020/10/3.
//  Copyright © 2020 Nixon Shih. All rights reserved.
//

import Foundation
import Utils

/// A data model that includes the informations of search
internal struct SearchInfo: Codable {
    internal static var empty: SearchInfo = SearchInfo()
    
    @Storage(key: "SearchInfo.current", defaultValue: empty)
    internal static var persisted: SearchInfo
    
    internal var targetPath: URL?
    internal var excludedPaths: [URL]
    internal var excludedFileNames: [String]
    
    internal init(targetPath: URL? = nil, excludedPaths: [URL] = [], excludeFileNames: [String] = []) {
        self.targetPath = targetPath
        self.excludedPaths = excludedPaths
        self.excludedFileNames = excludeFileNames
    }
}
