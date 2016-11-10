//
//  SearchFileNameResultViewController.swift
//  CheckSameFileName
//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Cocoa

class SearchFileNameResultViewController: NSViewController {
    
    /** 要搜尋的路徑 */
    var directoryPath: String?
    /** 想要排除在搜尋之外的資料夾 */
    var excludeFolders: [String]?
    /** 想要排除在搜尋之外的檔案名稱 */
    var excludeFileNames: [String]?
    
    @IBOutlet fileprivate weak var searchStatusLabel: NSTextField!
    @IBOutlet fileprivate weak var searchStatusIndicator: NSProgressIndicator!
    @IBOutlet fileprivate weak var searchResultTableView: NSTableView!

    /** 存放已經排序的結果 */
    fileprivate var searchResultDataSource = [SearchResult]()
    /** 存放尚未排序的結果 */
    fileprivate var tempSearchResult = [SearchResult]()
    fileprivate var searchFileBrain: SearchFileBrain?
    /** 負責更新畫面的 Timer */
    fileprivate var reloadTimer: Timer?
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let directoryPath = directoryPath {
            searchFileBrain = SearchFileBrain(directoryPath: directoryPath,
                                              excludeFolders: excludeFolders,
                                              excludeFileNames: excludeFileNames)
            searchFileBrain?.delegate = self
            searchFileBrain?.startSearch()
            
            reloadTimer = Timer.scheduledTimer(timeInterval: 1.5,
                                                                 target: self,
                                                                 selector: #selector(SearchFileNameResultViewController.sortAndReload),
                                                                 userInfo: nil,
                                                                 repeats: true)
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        searchFileBrain?.stopSearch()
        reloadTimer?.invalidate()
    }
    
    // MARK: - UI
    
    fileprivate func prepareUI() {
        searchStatusIndicator.startAnimation(nil)
        searchStatusLabel.stringValue = "搜尋中..."
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        let theMenu = NSMenu(title: "Contextual Menu")
        theMenu.insertItem(withTitle: "Show in Finder",
                                    action: #selector(SearchFileNameResultViewController.showInFinder(_:)),
                                    keyEquivalent: "ddd",
                                    at: 0)
        searchResultTableView.menu = theMenu
    }
    
    // MARK: - Event
    
    @objc fileprivate func showInFinder(_ sender: AnyObject) {
        let selectedRow = searchResultTableView.clickedRow
        let selectedSearchResult = searchResultDataSource[selectedRow]
        
        var error:NSError?
        let isExist = (selectedSearchResult.fileURL as NSURL).checkResourceIsReachableAndReturnError(&error)
        
        if isExist {
            NSWorkspace.shared().activateFileViewerSelecting([selectedSearchResult.fileURL as URL])
        }else{
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "警告"
            myPopup.informativeText = "該路徑不存在"
            myPopup.alertStyle = NSAlertStyle.warning
            myPopup.addButton(withTitle: "OK")
            myPopup.runModal()
        }
    }
    
    @objc fileprivate func sortAndReload() {
        searchResultDataSource = tempSearchResult.sorted { $0.fileName < $1.fileName }
        searchResultTableView.reloadData()
    }
    
    // MARK: - Data
    
    fileprivate func checkURLExist(_ searchResult: SearchResult) -> Bool {
        let filter = tempSearchResult.filter{
            $0.fileURL.absoluteString == searchResult.fileURL.absoluteString
        }
        return filter.count > 0
    }
    
}

// MARK: - NSTableViewDataSource NSTableViewDelegate
extension SearchFileNameResultViewController: NSTableViewDataSource,NSTableViewDelegate {
    
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        return searchResultDataSource.count
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        
        if let identifier = identifier {
            
            let cell = tableView.make(withIdentifier: identifier, owner: nil) as! NSTableCellView
            
            if identifier == "FileNameID" {
                cell.textField?.stringValue = searchResultDataSource[row].fileName
            }else if identifier == "FilePathID" {
                cell.textField?.stringValue = searchResultDataSource[row].filePath
            }
            
            return cell
        }
        
        return nil
    }
}

// MARK: - SearchFileBrainDelegate
extension SearchFileNameResultViewController: SearchFileBrainDelegate {
    
    internal func foundDuplicateFile(_ brain: SearchFileBrain, duplicateFiles: [SearchResult]) {
        for theSearchResult in duplicateFiles {
            if !checkURLExist(theSearchResult) {
                tempSearchResult.append(theSearchResult)
            }
        }
    }
    
    internal func searchFinish(_ brain: SearchFileBrain) {
        
        if reloadTimer != nil {
            reloadTimer?.invalidate()
            reloadTimer = nil
        }
        
        sortAndReload()
        searchStatusIndicator.isHidden = true
        searchStatusLabel.stringValue = "搜尋完成"
    }
    
    
    internal func searchError(_ brain: SearchFileBrain, errorMessage: String) {
        searchStatusIndicator.isHidden = true
        searchStatusLabel.stringValue = "搜尋失敗"
    }
}
