//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Cocoa
import FileExplorer

internal class SearchFileNameResultViewController: NSViewController {
    internal var searchInfo: SearchInfo = SearchInfo.empty
    
    @IBOutlet private weak var searchStatusLabel: NSTextField!
    @IBOutlet private weak var searchStatusIndicator: NSProgressIndicator!
    @IBOutlet private weak var searchResultTableView: NSTableView!
    
    private var fileExplorer: FileExplorer?
    private var searchResultDataSource = [URL]()
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let targetPath = searchInfo.targetPath {
            let excludedFileNamesSet = searchInfo.excludedFileNames.reduce(into: Set<String>()) { $0.insert($1) }
            let excludedDirectories = searchInfo.excludedPaths.reduce(into: Set<URL>()) { $0.insert($1) }
            let fileExplorer = FileExplorer(
                excludedInfo: ExcludedInfo(
                    fileNames: excludedFileNamesSet,
                    directories: excludedDirectories
                )
            )
            
            fileExplorer.findDuplicatedFile(at: targetPath) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.sync {
                    switch result {
                    case .success(let duplicatedPaths):
                        self.searchResultDataSource = duplicatedPaths
                        self.searchResultTableView.reloadData()
                        self.searchStatusIndicator.isHidden = true
                        self.searchStatusLabel.stringValue = "搜尋完成"
                        
                    case .failure(let error):
                        print(error)
                        self.searchStatusIndicator.isHidden = true
                        self.searchStatusLabel.stringValue = "搜尋失敗"
                    }
                }
            }
            
            fileExplorer.onStateChange = { [weak self] state in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.searchStatusLabel.stringValue = state.display
                }
            }
            
            self.fileExplorer = fileExplorer
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        fileExplorer?.stopSearch()
    }
    
    // MARK: - UI
    
    private func prepareUI() {
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
    
    @objc private func showInFinder(_ sender: AnyObject) {
        let selectedRow = searchResultTableView.clickedRow
        let selectedURL = searchResultDataSource[selectedRow]
        
        var error:NSError?
        let isExist = (selectedURL as NSURL).checkResourceIsReachableAndReturnError(&error)
        
        if isExist {
            NSWorkspace.shared.activateFileViewerSelecting([selectedURL as URL])
        }else{
            let myPopup: NSAlert = NSAlert()
            myPopup.messageText = "警告"
            myPopup.informativeText = "該路徑不存在"
            myPopup.alertStyle = NSAlert.Style.warning
            myPopup.addButton(withTitle: "OK")
            myPopup.runModal()
        }
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
            
            let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as! NSTableCellView
            
            if identifier.rawValue == "FileNameID" {
                cell.textField?.stringValue = searchResultDataSource[row].fileName
            }else if identifier.rawValue == "FilePathID" {
                cell.textField?.stringValue = searchResultDataSource[row].absoluteString
            }
            
            return cell
        }
        
        return nil
    }
}

extension FileExplorer.State {
    var display: String {
        switch self {
        case .idle: return "Idle"
        case .searching(let stage):
            switch stage {
            case .group: return "Processing..."
            case .checkDuplicated: return "Checking..."
            case .flat: return "Loading..."
            case .exclude: return "Almost complete..."
            }
        case .finish: return "Finish"
        }
    }
}
