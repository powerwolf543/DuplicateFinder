//
//  Created by NixonShih on 2016/10/6.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Cocoa
import FileExplorer
import Utils

internal final class SearchResultViewController: NSViewController {
    internal var searchInfo: SearchInfo = SearchInfo.empty
    
    @IBOutlet private weak var searchStatusLabel: NSTextField!
    @IBOutlet private weak var searchStatusIndicator: NSProgressIndicator!
    
    @IBOutlet
    private weak var searchResultTableView: NSTableView! {
        didSet {
            searchResultTableView.tableColumns[0].title = "result_page_table_column_file_name".localized
            searchResultTableView.tableColumns[1].title = "result_page_table_column_path".localized
        }
    }
    
    private var fileExplorer: FileExplorer?
    private var searchResultDataSource = [URL]()
    
    // MARK: - Override
    
    override
    internal func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override
    internal func viewWillAppear() {
        super.viewWillAppear()
        search()
    }
    
    override
    internal func viewWillDisappear() {
        super.viewWillDisappear()
        fileExplorer?.stopSearch()
    }
    
    // MARK: -
    
    private func prepareUI() {
        searchStatusIndicator.startAnimation(nil)
        searchStatusLabel.stringValue = "result_page_searching".localized
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        let theMenu = NSMenu(title: "Contextual Menu")
        theMenu.insertItem(withTitle: "result_page_show_in_finder".localized,
                           action: #selector(SearchResultViewController.showInFinder(_:)),
                           keyEquivalent: "",
                           at: 0)
        searchResultTableView.menu = theMenu
    }
    
    private func search() {
        guard let targetPath = searchInfo.targetPath else { return }
        
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
                    self.searchStatusLabel.stringValue = "result_page_search_complete".localized
                    
                case .failure(let error):
                    print(error)
                    self.searchStatusIndicator.isHidden = true
                    self.searchStatusLabel.stringValue = "result_page_search_failure".localized
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
    
    @objc
    private func showInFinder(_ sender: AnyObject) {
        let selectedRow = searchResultTableView.clickedRow
        let selectedURL = searchResultDataSource[selectedRow]
        
        var error: NSError?
        let isExist = (selectedURL as NSURL).checkResourceIsReachableAndReturnError(&error)
        
        guard isExist else {
            NSAlert(error: DuplicateFinderError.pathNotFound).runModal()
            return
        }
        
        NSWorkspace.shared.activateFileViewerSelecting([selectedURL as URL])
    }
}

// MARK: - NSTableViewDataSource NSTableViewDelegate
extension SearchResultViewController: NSTableViewDataSource, NSTableViewDelegate {
    internal func numberOfRows(in tableView: NSTableView) -> Int { searchResultDataSource.count }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let identifier = tableColumn?.identifier else { return nil }
        
        let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as! NSTableCellView
        
        switch identifier.rawValue {
        case "FileNameID":
            cell.textField?.stringValue = searchResultDataSource[row].fileName
        case "FilePathID":
            cell.textField?.stringValue = searchResultDataSource[row].absoluteString
        default: break
        }
        
        return cell
    }
}

fileprivate extension FileExplorer.State {
    var display: String {
        switch self {
        case .idle: return "file_explorer_state_idle".localized
        case .searching(let stage):
            switch stage {
            case .group: return "file_explorer_state_searching_group".localized
            case .checkDuplicated: return "file_explorer_state_searching_check_duplicated".localized
            case .flat: return "file_explorer_state_searching_flat".localized
            case .exclude: return "file_explorer_state_searching_exclude".localized
            }
        case .finish: return "file_explorer_state_finish".localized
        }
    }
}
