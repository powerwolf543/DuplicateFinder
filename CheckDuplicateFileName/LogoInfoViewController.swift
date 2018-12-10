//
//  Created by NixonShih on 2016/10/20.
//  Copyright © 2016 Nixon. All rights reserved.
//

import Cocoa

class LogoInfoViewController: NSViewController {
    
    @IBOutlet private weak var saveSearchSettingsSegmentedControl: NSSegmentedControl!
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    // MARK: - UI
    
    private func prepareUI() {
        let isEnable = SearchPreferences.shared.isStorageEnable
        saveSearchSettingsSegmentedControl.setSelected(true, forSegment: isEnable ? 1 : 0 )
    }
    
    // MARK: - Event
    
    @IBAction func saveSearchSegmentControlPressed(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            SearchPreferences.shared.isStorageEnable = false
        case 1:
            SearchPreferences.shared.isStorageEnable = true
        default:
            fatalError("Unknown selection.")
        }
    }
    
}
