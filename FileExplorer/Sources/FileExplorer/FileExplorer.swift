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
    
    private let pathValidator: PathValidator
    private var _state: State
    private let accessQueue: DispatchQueue
    
    /// Creates a `FileExplorer` with some settings.
    /// - Parameters:
    ///   - excludedInfo: The informations that includes all file paths and directory paths which need to exclude.
    public init(excludedInfo: ExcludedInfo = ExcludedInfo()) {
        _state = .idle
        self.pathValidator = PathValidator(excludedInfo: excludedInfo)
        accessQueue = DispatchQueue(label: "net.nixondesign.FindDuplicateFileName.FileExplorer.access")
    }
    
    /// Finds all duplicated file names in the specific directory
    /// - Parameter directoryURL: A directory url that you want to search.
    /// - Parameter isSkipsHiddenFiles: Pass `true` to skip the hidden files.
    /// - Parameter completionHandler: The callback that will be called on the search completion. 
    public func findDuplicatedFile(at directoryURL: URL, isSkipsHiddenFiles: Bool = true, completionHandler: @escaping (_ result: Result<[URL], FileExplorerError>) -> Void) {
        guard let pathIterator = DiskPathIterator(directoryURL: directoryURL, isSkipsHiddenFiles: isSkipsHiddenFiles) else {
            completionHandler(.failure(FileExplorerError.searchFail))
            return
        }
        
        findDuplicatedFile(with: pathIterator, completionHandler: completionHandler)
    }
    
    /// Finds all duplicated file names in the specific directory
    /// - Parameter diskPathIterator: A path iterator that aids with enumerating the whole directory.
    /// - Parameter completionHandler: The callback that will be called on the search completion.
    public func findDuplicatedFile(with diskPathIterator: PathIterator, completionHandler: @escaping (_ result: Result<[URL], FileExplorerError>) -> Void) {
        guard state == .idle else { return }
        
        DispatchQueue.global().async {
            self.state = .searching(.group)
            let groupedList = self.groupListByName(with: diskPathIterator)
            
            self.state = .searching(.checkDuplicated)
            let duplicatedFiles = groupedList.filter { $0.value.count > 1 }
            
            self.state = .searching(.flat)
            let flatDuplicatedFiles = duplicatedFiles.flatMap { $0.value }
            
            self.state = .searching(.exclude)
            let result = flatDuplicatedFiles.filter { !self.pathValidator.verifyPathNeedExcluded($0) }
            
            self.state = .finish
            completionHandler(.success(result))
        }
    }
    
    /// Interrupts the search
    public func stopSearch() {
        state = .finish
    }
    
    internal func groupListByName(with diskPathIterator: PathIterator) -> [String: Set<URL>] {
        var result: [String: Set<URL>] = [:]
        
        while let path = diskPathIterator.next() {
            guard pathValidator.verifyPathIsFile(path) else { continue }
            result[path.fileName, default: []].insert(path)
        }
        
        return result
    }
}
