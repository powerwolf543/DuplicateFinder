//
//  LogoInfoViewController.swift
//  CheckDuplicateFileName
//
//  Created by NixonShih on 2016/10/20.
//  Copyright © 2016年 Nixon. All rights reserved.
//

import Cocoa

class LogoInfoViewController: NSViewController {
    
    @IBOutlet fileprivate weak var saveSearchSettingsSegmentedControl: NSSegmentedControl!
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    // MARK: - UI
    
    fileprivate func prepareUI() {
        let isEnable = SearchPreferences.sharedInstance().isStorageEnable
        saveSearchSettingsSegmentedControl.setSelected(true, forSegment: isEnable ? 1 : 0 )
    }
    
    // MARK: - Event
    
    @IBAction func saveSearchSegmentControlPressed(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            SearchPreferences.sharedInstance().isStorageEnable = false
            break
        case 1:
            SearchPreferences.sharedInstance().isStorageEnable = true
            break
        default:
            break
        }
    }
    
}
