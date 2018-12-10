//
//  Created by NixonShih on 2016/10/5.
//  Copyright © 2016 Nixon. All rights reserved.
//

import Cocoa

class SelectDirectoryViewController: NSViewController,NSWindowDelegate {
    
    @IBOutlet private weak var filePathTextField: NSTextField!
    @IBOutlet fileprivate weak var excludeFolderTableView: NSTableView!
    @IBOutlet fileprivate weak var addFolderSegmentControl: NSSegmentedControl!
    @IBOutlet fileprivate weak var excludeFileNameTableView: NSTableView!
    @IBOutlet fileprivate weak var addExcludeFileNameSegmentControl: NSSegmentedControl!
    @IBOutlet private weak var excludeFileNameTextField: NSTextField!
    
    /** excludeFolderTableView's dataSource 如果沒有資料的時候，讓 addFolderSegmentControl 的減號設為 disable。 */
    fileprivate var excludeFolderDataSource = [String]() {
        didSet {
            if excludeFolderDataSource.count <= 0 {
                addFolderSegmentControl.setEnabled(false, forSegment: 1)
            }
            SearchPreferences.shared.excludeFolders = excludeFolderDataSource
        }
    }
    
    /** excludeFileNameTableView's dataSource 如果沒有資料的時候，讓 addExcludeFileNameSegmentControl 的減號設為 disable。 */
    fileprivate var excludeFileNameDataSource = [String]() {
        didSet {
            if excludeFileNameDataSource.count <= 0 {
                addExcludeFileNameSegmentControl.setEnabled(false, forSegment: 1)
            }
            SearchPreferences.shared.excludeFileNames = excludeFileNameDataSource
        }
    }
    
    /** excludeFolderTableView 當前選擇的 index */
    fileprivate var excludeFolderTableViewSelectedRow: Int?
    /** excludeFileNameTableView 當前選擇的 index */
    fileprivate var excludeFileNameTableViewSelectedRow: Int?
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
        
        excludeFolderTableView.dataSource = self
        excludeFolderTableView.delegate = self
        
        excludeFileNameTableView.dataSource = self
        excludeFileNameTableView.delegate = self
        
        let searchPreferences = SearchPreferences.shared
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
    @IBAction func addFolderSegmentPressed(_ sender: NSSegmentedControl) {
        
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
    
    @IBAction private func submitBtnPressed(_ sender: NSButton) {
        
        if filePathTextField.stringValue != "" {
            print("Selected directorie -> \"\(filePathTextField.stringValue)\"")
            
            let mainStoryboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
            searchResultWindowController = mainStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SearchFileNameResultWindowSID")) as? NSWindowController
            let searchFileNameResultVC = searchResultWindowController?.contentViewController as! SearchFileNameResultViewController
            searchFileNameResultVC.directoryPath = filePathTextField.stringValue
            searchFileNameResultVC.excludeFolders = excludeFolderDataSource
            searchFileNameResultVC.excludeFileNames = excludeFileNameDataSource
            searchResultWindowController?.showWindow(self)
        }
    }
    
    @objc private func filePathTextFieldClicked(_ sender: AnyObject) {
        
        let folderPath = getFolderPathFromFinder()
        
        if let folderPath = folderPath {
            SearchPreferences.shared.directoryPath = folderPath
            filePathTextField.stringValue = folderPath
        }
    }
    
    func windowWillClose(_ notification: Notification) {
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
            excludeFolderDataSource.remove(at: row)
            excludeFolderTableView.reloadData()
            excludeFolderTableViewSelectedRow = nil
        }else if sender == addExcludeFileNameSegmentControl {
            excludeFileNameDataSource.remove(at: row)
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
        if clickedResult == NSApplication.ModalResponse.OK {
            let url = openPanel.urls.first
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
    
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        
        if tableView == excludeFolderTableView {
            return excludeFolderDataSource.count
        }else if tableView == excludeFileNameTableView {
            return excludeFileNameDataSource.count
        }else{
            return 0
        }
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        
        if let identifier = identifier {
            
            let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as! NSTableCellView
            
            if identifier.rawValue == "FilePathCell_SID" {
                cell.textField?.stringValue = excludeFolderDataSource[row]
            }
            
            if identifier.rawValue == "FileNameCell_SID" {
                cell.textField?.stringValue = excludeFileNameDataSource[row]
            }
            
            return cell
        }
        
        return nil
    }
    
    internal func selectionShouldChange(in tableView: NSTableView) -> Bool {
        
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
