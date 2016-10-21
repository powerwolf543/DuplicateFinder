//
//  ViewController.swift
//  CheckSameFileName
//
//  Created by NixonShih on 2016/10/5.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Cocoa

class SelectDirectoryViewController: NSViewController,NSWindowDelegate {
    
    @IBOutlet private weak var filePathTextField: NSTextField!
    @IBOutlet private weak var excludeFolderTableView: NSTableView!
    @IBOutlet private weak var addFolderSegmentControl: NSSegmentedControl!
    @IBOutlet private weak var excludeFileNameTableView: NSTableView!
    @IBOutlet private weak var addExcludeFileNameSegmentControl: NSSegmentedControl!
    @IBOutlet private weak var excludeFileNameTextField: NSTextField!
    
    /** excludeFolderTableView's dataSource 如果沒有資料的時候，讓 addFolderSegmentControl 的減號設為 disable。 */
    private var excludeFolderDataSource = [String]() {
        didSet {
            if excludeFolderDataSource.count <= 0 {
                addFolderSegmentControl.setEnabled(false, forSegment: 1)
            }
            SearchPreferences.sharedInstance().excludeFolders = excludeFolderDataSource
        }
    }
    
    /** excludeFileNameTableView's dataSource 如果沒有資料的時候，讓 addExcludeFileNameSegmentControl 的減號設為 disable。 */
    private var excludeFileNameDataSource = [String]() {
        didSet {
            if excludeFileNameDataSource.count <= 0 {
                addExcludeFileNameSegmentControl.setEnabled(false, forSegment: 1)
            }
            SearchPreferences.sharedInstance().excludeFileNames = excludeFileNameDataSource
        }
    }
    
    /** excludeFolderTableView 當前選擇的 index */
    private var excludeFolderTableViewSelectedRow: Int?
    /** excludeFileNameTableView 當前選擇的 index */
    private var excludeFileNameTableViewSelectedRow: Int?
    private var searchResultWindowController:NSWindowController?
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear() {
        view.window?.delegate = self
    }
    
    // MARK: - UI
    
    private func prepareUI() {
        let gesture = NSClickGestureRecognizer()
        gesture.buttonMask = 0x1 // left mouse
        gesture.numberOfClicksRequired = 1
        gesture.target = self
        gesture.action = #selector(SelectDirectoryViewController.filePathTextFieldClicked(_:))
        filePathTextField.addGestureRecognizer(gesture)
        
        excludeFolderTableView.setDataSource(self)
        excludeFolderTableView.setDelegate(self)
        
        excludeFileNameTableView.setDataSource(self)
        excludeFileNameTableView.setDelegate(self)
        
        let searchPreferences = SearchPreferences.sharedInstance()
        if searchPreferences.isStorageEnable {
            if let directoryPath = searchPreferences.directoryPath {
                filePathTextField.stringValue = directoryPath
            }
            if let excludeFolders = searchPreferences.excludeFolders {
                excludeFolderDataSource = excludeFolders
            }
            if let excludeFileNames = searchPreferences.excludeFileNames {
                excludeFileNameDataSource = excludeFileNames
            }
        }
    }
    
    // MARK: - Event
    
    /** 0 為新增 1 為刪除 */
    @IBAction func addFolderSegmentPressed(sender: NSSegmentedControl) {
        
        switch sender.selectedSegment {
        case 0:
            if sender == addFolderSegmentControl {
                let folderPath = getFolderPathFromFinder()
                if let folderPath = folderPath {
                    dataSourceAdd(Data: folderPath, Sender: sender)
                }
            }else if sender == addExcludeFileNameSegmentControl {
                if excludeFileNameTextField.stringValue != "" {
                    dataSourceAdd(Data: excludeFileNameTextField.stringValue, Sender: sender)
                    excludeFileNameTextField.stringValue = ""
                }
            }
            break
        case 1:
            var row: Int?
            if sender == addFolderSegmentControl {
                row = excludeFolderTableViewSelectedRow
            }else if sender == addExcludeFileNameSegmentControl {
                row = excludeFileNameTableViewSelectedRow
            }
            dataSourceDeleteAt(Row: row,Sender: sender)
            break
        default:
            print("No this Option")
            break
        }
    }
    
    @IBAction private func submitBtnPressed(sender: NSButton) {
        
        if filePathTextField.stringValue != "" {
            print("Selected directorie -> \"\(filePathTextField.stringValue)\"")
            
            let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
            searchResultWindowController = mainStoryboard.instantiateControllerWithIdentifier("SearchFileNameResultWindowSID") as? NSWindowController
            let searchFileNameResultVC = searchResultWindowController?.contentViewController as! SearchFileNameResultViewController
            searchFileNameResultVC.directoryPath = filePathTextField.stringValue
            searchFileNameResultVC.excludeFolders = excludeFolderDataSource
            searchFileNameResultVC.excludeFileNames = excludeFileNameDataSource
            searchResultWindowController?.showWindow(self)
        }
    }
    
    @objc private func filePathTextFieldClicked(sender: AnyObject) {
        
        let folderPath = getFolderPathFromFinder()
        
        if let folderPath = folderPath {
            SearchPreferences.sharedInstance().directoryPath = folderPath
            filePathTextField.stringValue = folderPath
        }
    }
    
    func windowWillClose(notification: NSNotification) {
        //        searchResultWindowController?.close()
        NSApp.terminate(self)
    }
    
    // MARK: - File
    
    private func dataSourceAdd(Data data: String,Sender sender: NSSegmentedControl) {
        if sender == addFolderSegmentControl {
            excludeFolderDataSource.append(data)
            excludeFolderTableView.reloadData()
        }else if sender == addExcludeFileNameSegmentControl {
            excludeFileNameDataSource.append(data)
            excludeFileNameTableView.reloadData()
        }
    }
    
    private func dataSourceDeleteAt(Row row: Int?,Sender sender: NSSegmentedControl) {
        
        guard let row = row else { return }
        
        if sender == addFolderSegmentControl {
            excludeFolderDataSource.removeAtIndex(row)
            excludeFolderTableView.reloadData()
            excludeFolderTableViewSelectedRow = nil
        }else if sender == addExcludeFileNameSegmentControl {
            excludeFileNameDataSource.removeAtIndex(row)
            excludeFileNameTableView.reloadData()
            excludeFileNameTableViewSelectedRow = nil
        }
    }
    
    private func getFolderPathFromFinder() -> String? {
        // 開啟檔案瀏覽器
        let openPanel = NSOpenPanel()
        
        // 不允許多選檔案開啓
        // 不允許選擇目錄開啓
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        let clickedResult = openPanel.runModal()
        if clickedResult == NSModalResponseOK {
            let url = openPanel.URLs.first
            if let aURL = url {
                return aURL.absoluteString
            }
            return nil
        }
        return nil
    }
    
}

// MARK: - NSTableViewDataSource NSTableViewDelegate
extension SelectDirectoryViewController: NSTableViewDataSource,NSTableViewDelegate {
    
    internal func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        if tableView == excludeFolderTableView {
            return excludeFolderDataSource.count
        }else if tableView == excludeFileNameTableView {
            return excludeFileNameDataSource.count
        }else{
            return 0
        }
    }
    
    internal func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        
        if let identifier = identifier {
            
            let cell = tableView.makeViewWithIdentifier(identifier, owner: nil) as! NSTableCellView
            
            if identifier == "FilePathCell_SID" {
                cell.textField?.stringValue = excludeFolderDataSource[row]
            }
            
            if identifier == "FileNameCell_SID" {
                cell.textField?.stringValue = excludeFileNameDataSource[row]
            }
            
            return cell
        }
        
        return nil
    }
    
    internal func selectionShouldChangeInTableView(tableView: NSTableView) -> Bool {
        
        if tableView == excludeFolderTableView {
            
            if tableView.clickedRow == -1 {
                addFolderSegmentControl.setEnabled(false, forSegment: 1)
                excludeFolderTableViewSelectedRow = nil
            }else{
                addFolderSegmentControl.setEnabled(true, forSegment: 1)
                excludeFolderTableViewSelectedRow = tableView.clickedRow
            }
        }else if tableView == excludeFileNameTableView {
            
            if tableView.clickedRow == -1 {
                addExcludeFileNameSegmentControl.setEnabled(false, forSegment: 1)
                excludeFileNameTableViewSelectedRow = nil
            }else{
                addExcludeFileNameSegmentControl.setEnabled(true, forSegment: 1)
                excludeFileNameTableViewSelectedRow = tableView.clickedRow
            }
        }
        
        return true
    }
    
}
