//
//  Created by NixonShih on 2016/10/20.
//  Copyright © 2019 Nixon. All rights reserved.
//

import Foundation

/**
 **SettingPreferences**
 
 
 這個 Class 負責儲存搜尋的設定
 */
class SearchPreferences {
    
    // MARK: - singleton
    
    /// SearchPreferences's singleton instance
    static let shared = SearchPreferences()
    
    // MARK: - UserDefault IDs
    
    /** isStorageEnable's UserDefault ID */
    private static let isStorageEnableUDID = "isStorageEnableUDID"
    /** directoryPath's UserDefault ID */
    private static let directoryPathUDID = "directoryPathUDID"
    /** excludeFolders's UserDefault ID */
    private static let excludeFoldersUDID = "excludeFoldersUDID"
    /** excludeFileNames's UserDefault ID */
    private static let excludeFileNamesUDID = "iexcludeFileNamesUDID"
    
    // MARK: - Public properties
    
    /** 是否要儲存設定 */
    var isStorageEnable: Bool {
        didSet {
            if isStorageEnable {
                saveCurrentData()
            }else{
                cleanAllData()
            }
        }
    }
    
    /** 要搜尋的路徑 */
    var directoryPath: String? {
        didSet {
            if isStorageEnable {
                let userDefault = UserDefaults.standard
                userDefault.set(directoryPath, forKey: SearchPreferences.directoryPathUDID)
                userDefault.synchronize()
            }
        }
    }
    /** 想要排除在搜尋之外的資料夾 */
    var excludeFolders: [String]? {
        didSet {
            if isStorageEnable {
                let userDefault = UserDefaults.standard
                userDefault.set(excludeFolders, forKey: SearchPreferences.excludeFoldersUDID)
                userDefault.synchronize()
            }
        }
    }
    /** 想要排除在搜尋之外的檔案名稱 */
    var excludeFileNames: [String]? {
        didSet {
            if isStorageEnable {
                let userDefault = UserDefaults.standard
                userDefault.set(excludeFileNames, forKey: SearchPreferences.excludeFileNamesUDID)
                userDefault.synchronize()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private init () {
        let userDefault = UserDefaults.standard
        isStorageEnable = userDefault.bool(forKey: SearchPreferences.isStorageEnableUDID)
        loadLocalPreferencesData()
    }
    
    
    /** 將當前 SearchPreferences 資料儲存到本地端的 UserDefault。 */
    private func saveCurrentData() {
        let userDefault = UserDefaults.standard
        userDefault.set(isStorageEnable, forKey: SearchPreferences.isStorageEnableUDID)
        userDefault.set(directoryPath, forKey: SearchPreferences.directoryPathUDID)
        userDefault.set(excludeFolders, forKey: SearchPreferences.excludeFoldersUDID)
        userDefault.set(excludeFileNames, forKey: SearchPreferences.excludeFileNamesUDID)
        userDefault.synchronize()
    }
    
    /** 將本地的 UserDefault 有關 SearchPreferences 的資料清空 */
    private func cleanAllData() {
        let userDefault = UserDefaults.standard
        userDefault.set(false, forKey: SearchPreferences.isStorageEnableUDID)
        userDefault.set(nil, forKey: SearchPreferences.directoryPathUDID)
        userDefault.set(nil, forKey: SearchPreferences.excludeFoldersUDID)
        userDefault.set(nil, forKey: SearchPreferences.excludeFileNamesUDID)
        userDefault.synchronize()
    }
    
    /** 從本地端的 UserDefault 拿取資料 */
    private func loadLocalPreferencesData() {
        let userDefault = UserDefaults.standard
        directoryPath = userDefault.string(forKey: SearchPreferences.directoryPathUDID)
        excludeFolders = userDefault.stringArray(forKey: SearchPreferences.excludeFoldersUDID)
        excludeFileNames = userDefault.stringArray(forKey: SearchPreferences.excludeFileNamesUDID)
    }
    
}

