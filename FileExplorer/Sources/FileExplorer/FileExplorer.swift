//
//  FileExplorer.swift
//  Created by Nixon Shih on 2020/9/20.
//

import Foundation

/// The FileExplorer includes the feature that finds all duplicated file names
public final class FileExplorer {
    /// A state that represents the working state of `FileExplorer`
    public enum State: Equatable {
        case idle
        case searching(SearchStage)
        case finish
    }
    
    /// A stage that represents the searching state of `FileExplorer`
    public enum SearchStage: Equatable {
        case group
        case checkDuplicated
        case flat
        case exclude
    }
    
    public private(set) var state: State {
        set {
            accessQueue.sync { _state = newValue }
            onStateChange?(_state)
        }
        get {
            accessQueue.sync { _state }
        }
    }
    
    public var onStateChange: ((State) -> Void)?
    
    internal private(set) var diskPathIterator: PathIterator

    private let pathValidator: PathValidator
    private var _state: State
    private let accessQueue: DispatchQueue
    
    internal init(diskPathIterator: PathIterator, excludedInfo: ExcludedInfo = ExcludedInfo()) {
        _state = .idle
        self.diskPathIterator = diskPathIterator
        self.pathValidator = PathValidator(excludedInfo: excludedInfo)
        accessQueue = DispatchQueue(label: "net.nixondesign.FindDuplicateFileName.FileExplorer.access")
    }
    
    /// Finds all duplicated file names in the specific directory
    /// - Parameter completionHandler: The callback that will be called on the search completion.
    /// - Parameter duplicatedFiles: A `URL` array that includes all the duplicated files which represents the search result
    public func findDuplicatedFile(completionHandler: @escaping (_ duplicatedFiles: [URL]) -> Void) {
        guard state == .idle else { return }
        
        state = .searching(.group)
        DispatchQueue.global().async {
            let groupedList = self.groupListByName()
            
            self.state = .searching(.checkDuplicated)
            let duplicatedFiles = groupedList.filter { $0.value.count > 1 }
            
            self.state = .searching(.flat)
            let flatDuplicatedFiles = duplicatedFiles.flatMap { $0.value }
            
            self.state = .searching(.exclude)
            let result = flatDuplicatedFiles.filter { !self.pathValidator.verifyPathNeedExcluded($0) }
            
            self.state = .finish
            completionHandler(result)
        }
    }
    
    /// Interrupts the search
    public func stopSearch() {
        state = .finish
    }
    
    internal func groupListByName() -> [String: Set<URL>] {
        var result: [String: Set<URL>] = [:]
        
        while let path = diskPathIterator.next() {
            guard pathValidator.verifyPathIsFile(path) else { continue }
            result[path.fileName, default: []].insert(path)
        }
        
        return result
    }
}
