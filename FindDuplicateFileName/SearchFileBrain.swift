//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Foundation

/**
 **SearchFileBrainDelegate**
 
 
 遵守這個 Protocol 可以觸發檔案監控事件
 
 - func foundDuplicateFile(brain: SearchFileBrain, duplicateFiles: [SearchResult]) 找到重複的檔案就會觸發這個 Protocol func
 - func searchFinish(brain: SearchFileBrain) 搜尋結束就會觸發這個 Protocol func
 - func searchError(brain: SearchFileBrain, errorMessage: String) 搜尋錯誤就會觸發這個 Protocol func
 
 */
protocol SearchFileBrainDelegate {
    /**
     找到重複的檔案就會觸發這個 Protocol func
     - parameter brain:             發送這個事件的 Instance
     - parameter duplicateFiles:    重複的檔案
     */
    func foundDuplicateFile(_ brain: SearchFileBrain, duplicateFiles: [SearchResult])
    /**
     搜尋結束就會觸發這個 Protocol func
     - parameter brain:             發送這個事件的 Instance
     */
    func searchFinish(_ brain: SearchFileBrain)
    /**
     搜尋錯誤就會觸發這個 Protocol func
     - parameter brain:             發送這個事件的 Instance
     - parameter errorMessage:      錯誤訊息
     */
    func searchError(_ brain: SearchFileBrain, errorMessage: String)
}

/**
 **SearchFileBrain**
 
 
 這個 Class 負責搜尋檔案的邏輯部分
 
 - 使用 startSearch() 進行檔案搜尋
 - Conform SearchFileBrainDelegate 來監控當案收尋的狀況
 */
class SearchFileBrain {
    
    /// a path that you want to search 
    let directoryPath: String
    /** 只要存放在這個陣列的路徑，搜尋的時候都會排除。 */
    var excludeFolders: [String]?
    /** 只要存放在這個陣列的完整檔名(需包含副檔名)，搜尋的時候都會排除。 */
    var excludeFileNames: [String]?
    var delegate: SearchFileBrainDelegate?
    /** 將搜尋過的結果放在這個陣列中。 */
    private var searchResultStorage = [SearchResult]()
    /** 判斷是否要停止搜尋的 Flag，若要停止則設為 True。 */
    private var cancelSearchFlag = false
    
    /**
     Initializer
     
     - parameter directoryPath: a path that you want to search
     - parameter excludeFolders: folder names that you want to exclude
     - parameter excludeFileNames: file names that you want to exclude
     - returns: SearchFileBrain's Instance
     */
    init(directoryPath: String, excludeFolders: [String]?, excludeFileNames: [String]?) {
        self.directoryPath = directoryPath
        self.excludeFolders = excludeFolders
        self.excludeFileNames = excludeFileNames
    }
    
    // MARK: - Action
    
    /** 開始搜尋你所要求路徑的資料夾 */
    func startSearch() {
        DispatchQueue.global().async {
            self.enumeratorDirectory()
        }
    }
    
    /** 停止搜尋 */
    func stopSearch() {
        cancelSearchFlag = true
    }
    
    // MARK: - File Search
    
    /** 開始對資料夾進行檢索比對 */
    private func enumeratorDirectory() {
        
        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey]
        
        guard let directoryURL = URL(string: directoryPath)
            , let enumerator = fileManager.enumerator(at: directoryURL, includingPropertiesForKeys: keys, options:FileManager.DirectoryEnumerationOptions.skipsHiddenFiles,errorHandler: { aURL, aError in true })
            else { return }
        
        for fileURL in enumerator {
            
            if cancelSearchFlag { return }
            
            var isDir : ObjCBool = false
            guard
                fileManager.fileExists(atPath: (fileURL as AnyObject).path!, isDirectory: &isDir),
                !isDir.boolValue,
                let aFileURL = fileURL as? URL,
                !checkNeedExcludeOf(FolderPath: aFileURL.absoluteString),
                !checkNeedExcludeOf(FileName: aFileURL.lastPathComponent)
                else { continue }
            
            let theSearchResult = SearchResult(fileURL: aFileURL)
            if theSearchResult.fileName == ".DS_Store" { continue }
            
            var duplicateFiles = duplicateFilesInStorage(aFileURL)
            
            if duplicateFiles.count == 0 {
                searchResultStorage.append(theSearchResult)
            }else{
                duplicateFiles.append(theSearchResult)
                
                DispatchQueue.main.async(execute: {
                    self.delegate?.foundDuplicateFile(self,duplicateFiles: duplicateFiles)
                })
            }
        }
        
        DispatchQueue.main.async(execute: {
            self.delegate?.searchFinish(self)
        })
    }
    
    // MARK: - File Parser
    
    /** 比對有哪些檔案重複 */
    private func duplicateFilesInStorage(_ fileURL: URL) -> [SearchResult] {
        
        let fileName = fileURL.lastPathComponent
        return searchResultStorage.filter { $0.fileName == fileName }
    }
    
    /** 檢查路徑是否有在排除名單中 */
    private func checkNeedExcludeOf(FolderPath path: String) -> Bool {
        
        guard let excludeFolders = excludeFolders else {
            return false
        }
        
        if excludeFolders.count == 0 {
            return false
        }
        
        let filterResult = excludeFolders.filter { path.contains($0) }
        
        return filterResult.count != 0
    }
    
    /** 檢查是否有需要排除的檔名 */
    private func checkNeedExcludeOf(FileName name: String?) -> Bool {
        
        guard let excludeFileNames = excludeFileNames,let theName = name else {
            return false
        }
        
        if excludeFileNames.count == 0 {
            return false
        }
        
        let filterResult = excludeFileNames.filter { theName == $0 }
        
        return filterResult.count != 0
    }
    
}
