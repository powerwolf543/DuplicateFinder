//
//  Created by NixonShih on 2019/10/03.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Foundation
import Utils

/// Aids to access the search preferences
@dynamicMemberLookup
internal final class SearchPreference {
    internal static let shared: SearchPreference = SearchPreference()
    
    @Storage(key: "SearchPreferencesManager.isPersistedEnabled", defaultValue: false)
    internal static var isPersistedEnabled: Bool
    
    private let privateQueue: DispatchQueue
    
    private init() {
        privateQueue = DispatchQueue(label: "net.nixondesign.DuplicateFinder.SearchPreferencesManager")
    }
    
    internal subscript<T>(dynamicMember keyPath: WritableKeyPath<SearchInfo, T>) -> T {
        get {
            privateQueue.sync {
                if SearchPreference.isPersistedEnabled {
                    return SearchInfo.persisted[keyPath: keyPath]
                } else {
                    return SearchInfo.empty[keyPath: keyPath]
                }
            }
        }
        set {
            privateQueue.sync {
                SearchInfo.persisted[keyPath: keyPath] = newValue
            }
        }
    }
}
