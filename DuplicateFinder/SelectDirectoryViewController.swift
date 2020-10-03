//
//  Created by NixonShih on 2016/10/5.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Cocoa
import Utils

internal final class SearchSettingsViewController: NSViewController {
    @IBOutlet
    private weak var titleLabel: NSTextField! {
        didSet { titleLabel.stringValue = "setup_page_title".localized }
    }
    
    @IBOutlet
    private weak var filePathTextField: NSTextField! {
        didSet { filePathTextField.placeholderString = "setup_page_choose_folder_text_field_placehodler".localized }
    }
    
    @IBOutlet
    private weak var checkButton: NSButton! {
        didSet { checkButton.title = "setup_page_check_button_title".localized }
    }
    
    @IBOutlet
    private weak var excludedFolderTitleLabel: NSTextField! {
        didSet { excludedFolderTitleLabel.stringValue = "setup_page_excluded_folder_field_title".localized }
    }
    
    @IBOutlet
    private weak var excludedNamesTitleLabel: NSTextField! {
        didSet { excludedNamesTitleLabel.stringValue = "setup_page_excluded_names_field_title".localized }
    }
    
    @IBOutlet
    private weak var excludeFolderTableView: NSTableView! {
        didSet {
            excludeFolderTableView.tableColumns.first?.title = "setup_page_excluded_folder_table_column_title".localized
        }
    }
    
    @IBOutlet
    private weak var excludeFileNameTableView: NSTableView! {
        didSet {
            excludeFileNameTableView.tableColumns.first?.title = "setup_page_excluded_names_table_column_title".localized
        }
    }
    
    @IBOutlet
    private weak var excludeFileNameTextField: NSTextField! {
        didSet {
            excludeFileNameTextField.placeholderString = "setup_page_excluded_names_text_field_placehodler".localized
        }
    }
    
    @IBOutlet private weak var excludedPathsSegmentControl: NSSegmentedControl!
    @IBOutlet private weak var excludedFileNamesSegmentControl: NSSegmentedControl!
        
    private var excludePaths = [URL]() {
        didSet {
            excludedPathsSegmentControl.setEnabled(excludePaths.count > 0, forSegment: 1)
            SearchPreference.shared.excludedPaths = excludePaths
        }
    }
    
    private var excludedFileNames = [String]() {
        didSet {
            excludedFileNamesSegmentControl.setEnabled(excludedFileNames.count > 0, forSegment: 1)
            SearchPreference.shared.excludedFileNames = excludedFileNames
        }
    }
    
    private var excludeFolderTableViewSelectedRow: Int?
    private var excludeFileNameTableViewSelectedRow: Int?
    private var searchResultWindowController: NSWindowController?
    
    // MARK: - Override
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    internal override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.delegate = self
    }
    
    // MARK: -

    private func prepareUI() {
        let gesture = NSClickGestureRecognizer()
        gesture.buttonMask = 0x1 // left mouse
        gesture.numberOfClicksRequired = 1
        gesture.target = self
        gesture.action = #selector(SearchSettingsViewController.didClickFilePathTextField(_:))
        filePathTextField.addGestureRecognizer(gesture)
        
        excludeFolderTableView.dataSource = self
        excludeFolderTableView.delegate = self
        
        excludeFileNameTableView.dataSource = self
        excludeFileNameTableView.delegate = self
        
        let searchPreferenceManager = SearchPreference.shared
        filePathTextField.stringValue = searchPreferenceManager.targetPath?.absoluteString ?? ""
        excludePaths = searchPreferenceManager.excludedPaths
        excludedFileNames = searchPreferenceManager.excludedFileNames
    }
    
    private func getFolderPathFromFinder() -> URL? {
        // Open file browser
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        let clickedResult = openPanel.runModal()
        
        guard clickedResult == NSApplication.ModalResponse.OK,
            let url = openPanel.urls.first
            else { return nil }
        return url
    }
    
    /// sender.selectedSegment: 0 is appended, 1 is deleted
    @IBAction
    private func didChangeValueOfExcludeSegment(_ sender: NSSegmentedControl) {
        switch (sender.selectedSegment, sender) {
        case (0, excludedPathsSegmentControl):
            guard let path = getFolderPathFromFinder() else { break }
            excludePaths.append(path)
            excludeFolderTableView.reloadData()
            
        case (0, excludedFileNamesSegmentControl):
            guard !excludeFileNameTextField.stringValue.isEmpty else { break }
            excludedFileNames.append(excludeFileNameTextField.stringValue)
            excludeFileNameTableView.reloadData()
            excludeFileNameTextField.stringValue = ""
            
        case (1, excludedPathsSegmentControl):
            guard let row = excludeFolderTableViewSelectedRow else { return }
            excludePaths.remove(at: row)
            excludeFolderTableView.reloadData()
            excludeFolderTableViewSelectedRow = nil
            
        case (1, excludedFileNamesSegmentControl):
            guard let row = excludeFileNameTableViewSelectedRow else { return }
            excludedFileNames.remove(at: row)
            excludeFileNameTableView.reloadData()
            excludeFileNameTableViewSelectedRow = nil
            
        default:
            fatalError("Unknown option")
        }
    }
    
    @IBAction
    private func didClickCheckButton(_ sender: NSButton) {
        guard !filePathTextField.stringValue.isEmpty else {
            NSAlert(error: DuplicateFinderError.targetFolderNotFound).runModal()
            return
        }
        
        print("Selected directorie -> \"\(SearchInfo.persisted.targetPath?.absoluteString ?? "")\"")
        
        searchResultWindowController = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SearchFileNameResultWindowSID")) as? NSWindowController
        let vc = searchResultWindowController?.contentViewController as! SearchResultViewController
        vc.searchInfo = SearchInfo.persisted
        searchResultWindowController?.showWindow(self)
    }
    
    @objc
    private func didClickFilePathTextField(_ sender: AnyObject) {
        guard let targetPath = getFolderPathFromFinder() else { return }
        
        SearchPreference.shared.targetPath = targetPath
        filePathTextField.stringValue = targetPath.absoluteString
    }
}

// MARK: - NSTableViewDataSource NSTableViewDelegate
extension SearchSettingsViewController: NSTableViewDataSource, NSTableViewDelegate {
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case excludeFolderTableView:
            return excludePaths.count
        case excludeFileNameTableView:
            return excludedFileNames.count
        default:
            fatalError("Unrecogniz tableView.")
        }
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else { return nil }
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as! NSTableCellView
        
        switch identifier.rawValue {
        case "FilePathCell_SID":
            cell.textField?.stringValue = excludePaths[row].absoluteString
        case "FileNameCell_SID":
            cell.textField?.stringValue = excludedFileNames[row]
        default: break
        }
        
        return cell
    }
    
    internal func selectionShouldChange(in tableView: NSTableView) -> Bool {
        switch tableView {
        case excludeFolderTableView:
            if tableView.clickedRow == -1 {
                excludedPathsSegmentControl.setEnabled(false, forSegment: 1)
                excludeFolderTableViewSelectedRow = nil
            }else{
                excludedPathsSegmentControl.setEnabled(true, forSegment: 1)
                excludeFolderTableViewSelectedRow = tableView.clickedRow
            }
        case excludeFileNameTableView:
            if tableView.clickedRow == -1 {
                excludedFileNamesSegmentControl.setEnabled(false, forSegment: 1)
                excludeFileNameTableViewSelectedRow = nil
            }else{
                excludedFileNamesSegmentControl.setEnabled(true, forSegment: 1)
                excludeFileNameTableViewSelectedRow = tableView.clickedRow
            }
        default:
            fatalError("Unrecogniz tableView.")
        }
        return true
    }
}

// MARK: - NSWindowDelegate
extension SearchSettingsViewController: NSWindowDelegate {
    internal func windowWillClose(_ notification: Notification) {
        NSApp.terminate(self)
    }
}
