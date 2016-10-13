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
    @IBOutlet weak var excludeFolderTableView: NSTableView!
    @IBOutlet weak var addFolderSegmentControl: NSSegmentedControl!
    
    private var excludeFolderDataSource = [String]()
    private var fileNames = Set<String>()
    private var searchResultWindowController:NSWindowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear() {
        view.window?.delegate = self
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // MARK: UI
    
    private func prepareUI() {
        let gesture = NSClickGestureRecognizer()
        gesture.buttonMask = 0x1 // left mouse
        gesture.numberOfClicksRequired = 1
        gesture.target = self
        gesture.action = #selector(SelectDirectoryViewController.filePathTextFieldClicked(_:))
        filePathTextField.addGestureRecognizer(gesture)
        
        excludeFolderTableView.setDataSource(self)
        excludeFolderTableView.setDelegate(self)
    }
    
    // MARK: Event
    
    @IBAction func addFolderSegmentPressed(sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            let folderPath = getFolderPathFromFinder()
            if let folderPath = folderPath {
                dataSourceAdd(folderPath)
            }
            break
        case 1: break
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
            searchResultWindowController?.showWindow(self)
        }
    }
    
    @objc private func filePathTextFieldClicked(sender: AnyObject) {
        
        let folderPath = getFolderPathFromFinder()
        
        if let folderPath = folderPath {
            filePathTextField.stringValue = folderPath
        }
    }
    
    func windowWillClose(notification: NSNotification) {
        //        searchResultWindowController?.close()
        NSApp.terminate(self)
    }
    
    // MARK: File
    
    private func dataSourceAdd(folderPath: String) {
        excludeFolderDataSource.append(folderPath)
        excludeFolderTableView.reloadData()
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

// MARK: NSTableViewDataSource
extension SelectDirectoryViewController: NSTableViewDataSource,NSTableViewDelegate {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return excludeFolderDataSource.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn?.identifier
        
        if let identifier = identifier {
            
            let cell = tableView.makeViewWithIdentifier(identifier, owner: nil) as! NSTableCellView
            
            if identifier == "filePathCell_SID" {
                cell.textField?.stringValue = excludeFolderDataSource[row]
            }
            return cell
        }
        return nil
    }
    
}
