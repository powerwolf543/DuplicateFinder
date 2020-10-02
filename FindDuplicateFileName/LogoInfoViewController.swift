//
//  Created by NixonShih on 2016/10/20.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Cocoa
import Utils

internal class LogoInfoViewController: NSViewController {
    
    @IBOutlet private weak var savePreferenceCheckBox: NSButton! {
        didSet {
            savePreferenceCheckBox.title = "save_preference_check_box_title".localized
        }
    }
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    // MARK: - UI
    
    private func prepareUI() {
        let isEnable = SearchPreferences.shared.isStorageEnable
        savePreferenceCheckBox.state = isEnable ? .on : .off
    }
    
    // MARK: - Event
    
    @IBAction func didClickPreferenceButton(_ sender: NSButton) {
        switch sender.state {
        case .on: SearchPreferences.shared.isStorageEnable = true
        case .off: SearchPreferences.shared.isStorageEnable = false
        default: assertionFailure("Unknown case")
        }
    }
}
