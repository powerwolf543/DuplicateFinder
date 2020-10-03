//
//  Created by NixonShih on 2016/10/20.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Cocoa
import Utils

internal final class WelcomeViewController: NSViewController {
    @IBOutlet
    private weak var savePreferenceCheckBox: NSButton! {
        didSet { savePreferenceCheckBox.title = "save_preference_check_box_title".localized }
    }
    
    // MARK: - Override
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    // MARK: -
    
    private func prepareUI() {
        let isPersistedEnabled = SearchPreference.isPersistedEnabled
        savePreferenceCheckBox.state = isPersistedEnabled ? .on : .off
    }
    
    @IBAction
    private func didClickPreferenceButton(_ sender: NSButton) {
        switch sender.state {
        case .on: SearchPreference.isPersistedEnabled = true
        case .off: SearchPreference.isPersistedEnabled = false
        default: assertionFailure("Unknown case")
        }
    }
}
