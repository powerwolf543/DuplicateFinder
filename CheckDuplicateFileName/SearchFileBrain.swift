//
//  SearchFileBrain.swift
//  CheckSameFileName
//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Foundation

protocol SearchFileBrainDelegate {
    func foundDuplicateFile(duplicateFiles: [SearchResult])
    func searchFinish()
    func searchError(errorMessage: String)
}

class SearchFileBrain {
    
    let directoryPath: String
    var delegate: SearchFileBrainDelegate?
    private var searchResultStorage = [SearchResult]()
    
    init(directoryPath: String) {
        self.directoryPath = directoryPath
    }
    
    func startSearch() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.enumeratorDirectory()
        }
    }
    
    private func enumeratorDirectory() {
        let fileManager = NSFileManager()
        let directoryURL = NSURL(string: directoryPath)
        let keys = [NSURLIsDirectoryKey]
        
        if let directoryURL = directoryURL {
            let enumerator = fileManager.enumeratorAtURL(directoryURL, includingPropertiesForKeys: keys, options:NSDirectoryEnumerationOptions.SkipsHiddenFiles,errorHandler: {aURL, aError in true})
            
            if let enumerator = enumerator {
                for fileURL in enumerator {
                    var isDir : ObjCBool = false
                    if fileManager.fileExistsAtPath(fileURL.path!, isDirectory: &isDir) {
                        if !isDir {
                            let aFileURL = fileURL as! NSURL
                            let theSearchResult = SearchResult(fileURL: aFileURL)
                            
                            if theSearchResult.fileName == ".DS_Store" {
                                continue
                            }
                            
                            var duplicateFiles = duplicateFilesInStorage(aFileURL)
                            
                            if duplicateFiles.count == 0 {
                                searchResultStorage.append(theSearchResult)
                            }else{
                                duplicateFiles.append(theSearchResult)
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    self.delegate?.foundDuplicateFile(duplicateFiles)
                                })
                            }
                        }
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.delegate?.searchFinish()
                })
                
            }
        }
    }
    
    private func duplicateFilesInStorage(fileURL: NSURL) -> [SearchResult] {
        
        let fileName = fileURL.lastPathComponent
        return searchResultStorage.filter { $0.fileName == fileName! }
    }
    
}