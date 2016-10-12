//
//  SearchFileNameResultViewController.swift
//  CheckSameFileName
//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Cocoa

class SearchFileNameResultViewController: NSViewController,NSTableViewDelegate {
    
    var directoryPath: String?
    
    @IBOutlet private weak var searchStatusLabel: NSTextField!
    @IBOutlet private weak var searchStatusIndicator: NSProgressIndicator!
    @IBOutlet private weak var searchResultTableView: NSTableView!
    
    private var searchResultDataSource = [SearchResult]()
    private var tempSearchResult = [SearchResult]()
    private var searchFileBrain: SearchFileBrain?
    private var reloadTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let directoryPath = directoryPath {
            searchFileBrain = SearchFileBrain(directoryPath: directoryPath)
            searchFileBrain?.delegate = self
            searchFileBrain?.startSearch()
            
            reloadTimer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(SearchFileNameResultViewController.sortAndReload), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: UI
    
    private func prepareUI() {
        searchStatusIndicator.startAnimation(nil)
        searchStatusLabel.stringValue = "搜尋中..."
        searchResultTableView.setDataSource(self)
        searchResultTableView.setDelegate(self)
        
        
        let theMenu = NSMenu(title: "Contextual Menu")
        theMenu.insertItemWithTitle("Show in Finder", action: #selector(SearchFileNameResultViewController.showInFinder(_:)), keyEquivalent: "ddd", atIndex: 0)
        searchResultTableView.menu = theMenu
    }
    
    // MARK: Event
    
    @objc private func showInFinder(sender: AnyObject) {
        let selectedRow = searchResultTableView.clickedRow
        let selectedSearchResult = searchResultDataSource[selectedRow]
        NSWorkspace.sharedWorkspace().activateFileViewerSelectingURLs([selectedSearchResult.fileURL])
    }
    
    @objc private func sortAndReload() {
        searchResultDataSource = tempSearchResult.sort { $0.fileName > $1.fileName }
        searchResultTableView.reloadData()
    }
    
    // MARK: Data
    
    private func checkURLExist(searchResult: SearchResult) -> Bool {
        let filter = tempSearchResult.filter{
            $0.fileURL.absoluteString == searchResult.fileURL.absoluteString
        }
        return filter.count > 0
    }
    
}

// MARK: NSTableViewDataSource
extension SearchFileNameResultViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return searchResultDataSource.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        
        if let identifier = identifier {
            
            let cell = tableView.makeViewWithIdentifier(identifier, owner: nil) as! NSTableCellView
            
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

// MARK: SearchFileBrainDelegate
extension SearchFileNameResultViewController: SearchFileBrainDelegate {
    
    func foundDuplicateFile(brain: SearchFileBrain, duplicateFiles: [SearchResult]) {
        for theSearchResult in duplicateFiles {
            if !checkURLExist(theSearchResult) {
                tempSearchResult.append(theSearchResult)
            }
        }
    }
    
    func searchFinish(brain: SearchFileBrain) {
        
        if reloadTimer != nil {
            reloadTimer?.invalidate()
            reloadTimer = nil
        }
        
        sortAndReload()
        searchStatusIndicator.hidden = true
        searchStatusLabel.stringValue = "搜尋結果"
    }

    
    func searchError(brain: SearchFileBrain, errorMessage: String) {
        searchStatusIndicator.hidden = true
        searchStatusLabel.stringValue = "搜尋失敗"
    }
}
